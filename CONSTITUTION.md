# CONSTITUTION.md — .lol Family DNA

## What We Are

Developer tools that respect developers. Each tool does one thing well, gives you the answer fast, and gets out of the way. No BS — no accounts, no tracking, no paywalls, no marketing fluff. You type a domain, you get an answer.

## Family Structure

```
certs.lol ──→ yoke.lol    (TLS scanner → hub)
ns.lol    ──→ yoke.lol    (DNS toolkit → hub)
vrfy.lol       standalone  (email validation)
xhttp.lol      standalone  (HTTP response debugger)
```

**Yoke is the hub.** certs.lol and ns.lol are feeder tools that link users to Yoke for the full picture. vrfy.lol and xhttp.lol are standalone — they don't funnel to Yoke.

Every tool in the family shares: the same design language, the same terminal-first UX, the same API conventions, the same CLI patterns, and the same infrastructure standards. See the sister docs for details.

## Core Principles

### No Accounts, No Tracking
- No signups. No API keys for basic use.
- No analytics beyond CF Analytics (privacy-preserving, no cookies).
- Proof of Work for abuse prevention — computational cost, not bureaucratic friction.

### Public Status Page

Every tool exposes `/status` — a server-rendered HTML page showing the health of external API dependencies the tool relies on. No auth required, no client JS needed. This is how operators (and users) know whether the service is healthy without digging through logs. The status page must be styled consistently with the family design system (dark-mode-first, Inter + JetBrains Mono, same color tokens). If the tool tracks errors in KV or D1, the status page surfaces them. If not, it shows a simple heartbeat.

### Three Equal Interfaces

The family has three first-class interfaces. None is secondary:

1. **API** — `curl -s https://{tool}.lol/{domain}` is the canonical interface. Content negotiation: browsers get HTML, API clients get JSON. `Accept: application/json` always returns structured data.

2. **Web UI** — The SPA. Terminal-style input (`$ {tool} ▸`), dark-mode-first, same data the API returns but pretty. Not a wrapper — it's the same Worker serving both.

3. **CLI** — Go binary, Homebrew tap, curl|bash installer. Every tool ships a CLI that calls the API. Same output formatting conventions, same flags (`--json`, `--quiet`, `--no-color`), same exit codes (0/1/2). See CLI-UX.md.

### Self-Hosting

**Current path (Option A — ship now):** Yoke-only self-host. Yoke is designed to be self-hostable — run your own instance against your own domains. No hard dependencies on external services that can't be swapped, documented environment variables, Docker-friendly, and the API is the product (not the hosted instance). Satellites (certs, ns, vrfy, xhttp) are open source — self-hosting them is possible but best-effort.

**North star (Option B):** Full white-label stack. Dedicated domain with subdomains per tool (e.g. ns.yoke-test.lol, certs.yoke-test.lol), fully self-hostable and white-labelable. Everything works out of the box as a cohesive self-hosted suite.

**Rejected (Option C):** Separate codebases or versions for self-hosting vs production.

**Constraint:** Nothing deployed now can be fundamentally incompatible with Option B. Every satellite integration must be behind an interface where the backing implementation (CF binding vs HTTP call vs localhost) is swappable by config, not by code change. B should be additive, not a rewrite.

### POST-Only for PII
- Email addresses, personal identifiers never appear in URLs.
- This keeps them out of server logs, CDN analytics, browser history, and Referer headers.

### PoW Over API Keys
- Rate limiting uses progressive enforcement with proof-of-work.
- Under threshold: free, unlimited. Over threshold: solve a SHA-256 hashcash challenge.
- Client libraries handle PoW transparently. Raw API users solve manually.
- Economics: at abuse scale, PoW makes it cheaper to use a paid service.

### $5/mo Per Tool
- Each tool runs on Cloudflare Workers Paid ($5/mo).
- Fly.io probes where Workers can't reach (TLS handshakes, UDP DNS).
- No databases unless necessary (KV + D1 where needed, stateless where possible).
- Cost discipline is a feature, not a constraint.

### Open Core Where Applicable
- MIT engine + proprietary extensions via CF Service Bindings.
- Open source by default. Monetization pending conflicts review.
- **vrfy.lol model:** Open source validation engine (MIT) + closed-source existence plugin (proprietary). Worker has optional `EXISTENCE_SERVICE` binding → calls separate closed-source existence Worker. If binding absent, `existence: null`. Self-hosters get basic validation. Production gets everything.
- **Production service bindings:** Yoke calls satellite workers via CF Service Bindings (perf win, no egress). Satellites stay fully independent — they work without yoke. The binding is an optimization, not a dependency.

## Brand DNA

### Name Philosophy
- "A yoke is for those who pull the load" — support teams, consultants, freelancers.
- ".lol" is a nod to teams that name internal tools things like "trogdor" or "WOPR."
- Each tool has a short, memorable, lowercase name.

### Design DNA
- Inter (sans) + JetBrains Mono (mono)
- Dark-mode-first, terminal/hacker aesthetic
- Terminal prompt input (`$ {tool} ▸`) is the signature UX element across the family
- curl-first UX — the tool should feel like a CLI that happens to have a web UI
- Each tool has a signature accent color (see DESIGN-SYSTEM.md)
- Consistent footer: family links, Yoke badge, dot-separated nav

### Voice
- Direct, technical, no marketing fluff
- "Fast, API-first DNS toolkit" not "Revolutionize your DNS workflow"
- Error messages explain what happened and how to fix it
- Docs are reference, not tutorials
