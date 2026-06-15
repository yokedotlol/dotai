# PROBES.md — Probe Architecture & Multi-Region Strategy

## Why Probes Exist

Cloudflare Workers can't:
- Make raw TLS connections (needed for cipher suite detection, certificate chain extraction)
- Send UDP packets (needed for real DNS resolver queries)
- Control TCP connection parameters (needed for STARTTLS, SNI manipulation)

So we run lightweight probe services on Fly.io that handle the low-level protocol work.

## Current Probe Architecture

### yoke-probe (Go, Fly.io)
- **Purpose:** TLS handshake analysis for certs.lol and Yoke's security checks
- **Location:** `yoke-probe.fly.dev`, primary region `sjc`
- **Capabilities:** Full TLS probe — cipher suites, extensions, certificate chains, STARTTLS, uTLS fingerprinting
- **Auth:** Bearer token (`PROBE_KEY` env var)
- **Code:** `~/workspace/certs-lol/probe/` (Go)

### ns-lol-probe (Node.js, Fly.io)
- **Purpose:** Real UDP DNS queries to global resolvers (CF Workers can only do DoH)
- **Location:** `ns-lol-probe.fly.dev`, primary region `sjc`
- **Capabilities:** Propagation checks across 15 global resolvers, authoritative NS queries, DNSSEC validation
- **Auth:** Query parameter key
- **Code:** `~/workspace/ns-lol-probe/` (Node.js)

### Direct Worker Fetches (Yoke)
- **Purpose:** HTTP probing — headers, redirects, tech stack detection, content analysis
- **Runs from:** CF Worker edge (varies by user location)
- **User-Agent varies:**
  - Bot-style: `Mozilla/5.0 (compatible; Yoke/1.0)`, `YokeBot/1.0`
  - Browser-style: `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ...`

## Problem: Blocked Probes

Sites like Meta, GoDaddy, and other large properties block our probes. They detect us via:

1. **IP reputation** — CF Worker egress IPs and Fly.io IPs are known cloud/datacenter ranges
2. **User-Agent** — bot-style UAs (`Yoke/1.0`, `certs.lol/1.0`) trigger immediate blocks
3. **Behavioral** — single request patterns, no JavaScript execution, no cookie handling
4. **Rate-based** — repeated requests from same IP

## Multi-Region Probe Strategy

### Goal
Run probe services across multiple Fly regions so we can:
1. **Failover** — if one region's IP is blocked, try another
2. **Geo-diversity** — test from different network paths
3. **Resilience** — no single point of failure

### Proposed Architecture

```
CF Worker (edge)
  ├── Try probe in region A (e.g. sjc)
  │   ├── Success → return result
  │   └── Blocked (403/429/timeout) → try region B
  ├── Try probe in region B (e.g. iad)
  │   ├── Success → return result
  │   └── Blocked → try region C
  └── Try probe in region C (e.g. ams)
      ├── Success → return result
      └── All blocked → return partial result with "probe blocked" flag
```

### Fly Region Selection

Priority regions (diverse network paths, good connectivity):
1. `sjc` — San Jose (current, US West)
2. `iad` — Ashburn (US East, major peering point)
3. `ams` — Amsterdam (Europe)
4. `nrt` — Tokyo (Asia-Pacific, optional)

Use `fly-prefer-region` header to route to specific machines. Fly handles this natively.

### Implementation Pattern

```typescript
async function probeWithFailover(
  env: Env, 
  endpoint: string, 
  regions: string[] = ['sjc', 'iad', 'ams']
): Promise<ProbeResult> {
  for (const region of regions) {
    try {
      const resp = await fetch(`${env.PROBE_URL}${endpoint}`, {
        headers: {
          'Authorization': `Bearer ${env.PROBE_KEY}`,
          'fly-prefer-region': region,
        },
        signal: AbortSignal.timeout(10000),
      });
      
      if (resp.ok) {
        const data = await resp.json();
        return { ...data, probe_region: region };
      }
      
      // Target site blocked us — try next region
      if (resp.status === 403 || resp.status === 429) continue;
      
      // Probe error (not target block) — still try next
      continue;
    } catch (e) {
      // Timeout or network error — try next region
      continue;
    }
  }
  
  return { error: 'probe_blocked', message: 'All probe regions blocked by target' };
}
```

### Cost Impact

Fly.io pricing for `shared-cpu-1x` (256MB):
- Auto-stop machines: ~$0 when idle (only charged for running time)
- 3 regions × minimal usage = negligible cost increase
- Well within the $5/mo budget philosophy

## User-Agent Strategy

### Principle: Look Natural, Be Honest

We should look like a normal browser to avoid false-positive blocks, while still being identifiable if someone investigates.

### Recommended UA Rotation

**Primary (used for HTTP probes):**
```
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36
```

**Rotation pool (cycle through to avoid fingerprinting):**
```
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36
Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Safari/605.1.15
```

**For API-to-API calls (HIBP, Brandfetch, etc.):**
Keep the honest bot UA — these APIs expect and accept bots:
```
YokeBot/1.0 (+https://yoke.lol)
```

### What NOT to Do
- Don't use the exact same UA for every request (fingerprinting)
- Don't use obviously fake UAs
- Don't randomize unrealistically (no Chrome 47 on Windows 11)
- Don't set bot UAs when probing websites that block bots

### Additional Headers for Natural Requests

```
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.9
Accept-Encoding: gzip, deflate, br
Connection: keep-alive
Sec-Fetch-Dest: document
Sec-Fetch-Mode: navigate
Sec-Fetch-Site: none
Sec-Fetch-User: ?1
Upgrade-Insecure-Requests: 1
```

These headers make requests look like a real browser navigation rather than a `fetch()` from a script.

## Unified Probe Service

### Future: Consolidate into One Probe

Currently we have two separate Fly apps. Consider consolidating into one:

```
probe.lol (or yoke-probe.fly.dev)
  /tls     — TLS handshake analysis (Go)
  /dns     — UDP DNS queries (Node.js or Go)
  /http    — HTTP probing with natural headers (Go)
```

This would:
- Simplify deployment (one Fly app, multi-region)
- Share the failover logic
- Centralize UA rotation and anti-block strategy
- Reduce operational surface

### Migration Path
1. Add HTTP probing to the Go probe service
2. Rewrite DNS probing in Go (replace Node.js)
3. Deploy single probe across 3 regions
4. Update all Workers to use unified probe URL
5. Decommission ns-lol-probe

This is a Phase 2 optimization — the multi-region failover can be added to the existing separate probes first.
