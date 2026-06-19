# API-CONVENTIONS.md — API Design Standards

## URL Pattern

```
GET  /{domain}              — Full scan (primary endpoint)
GET  /{domain}/{section}    — Section-specific scan
POST /{endpoint}            — Actions requiring body (POST-only for PII)
```

## Content Negotiation

```
Accept: text/html              → SPA HTML page
Accept: application/json       → JSON API response
Accept: application/dns-json   → DNS JSON format (ns.lol only)
curl (no Accept header)        → JSON (API-first default)
Browser (Accept: text/html)    → SPA
```

## Response Envelope

Every API response includes a `_meta` block:

```json
{
  "domain": "example.com",
  "scanned_at": "2026-06-15T21:00:00Z",
  
  "...tool-specific fields...",
  
  "_meta": {
    "tool": "{tool}.lol",
    "version": "1.0",
    "cached": false,
    "cache_ttl": 300,
    "query_time_ms": 1234,
    "full_report": "https://yoke.lol/example.com"
  }
}
```

**`full_report`** is included ONLY for feeder tools (certs.lol, ns.lol). Omit for standalone tools (vrfy.lol, xhttp.lol). See FUNNEL.md.

## Error Responses

Consistent error shape across all tools — flat object with `error` string and optional detail fields:

```json
{
  "error": "The domain 'not a domain' is not valid.",
  "code": "INVALID_DOMAIN"
}
```

HTTP status is conveyed by the response status code. Optional fields like `retry_after`, `detail`, or `input` may be included when relevant.

### Standard Error Codes

| Code | Status | Meaning |
|------|--------|---------|
| `INVALID_DOMAIN` | 400 | Domain/input failed validation |
| `INVALID_TYPE` | 400 | Unknown record type, scan type, etc. |
| `RATE_LIMITED` | 429 | Rate limit exceeded (include PoW challenge if applicable) |
| `PROBE_BLOCKED` | 502 | Target site blocked all probe attempts |
| `PROBE_ERROR` | 502 | Probe service error (timeout, crash) |
| `UPSTREAM_ERROR` | 502 | Third-party API error |
| `NOT_FOUND` | 404 | Unknown endpoint |
| `INTERNAL_ERROR` | 500 | Unexpected error |

## Rate Limiting

### Headers
```
X-RateLimit-Limit: 120
X-RateLimit-Remaining: 118
X-RateLimit-Reset: 1718488800
```

### PoW Challenge (429 response)
```json
{
  "error": "Rate limit exceeded. Solve the proof-of-work challenge to continue.",
  "code": "RATE_LIMITED",
  "pow": {
    "challenge": "a1b2c3d4...",
    "difficulty": 4,
    "algorithm": "sha256",
    "expires": 1718489100
  }
}
```

### Retry-After
- `Retry-After: 0` on PoW challenges (solve immediately, don't wait)
- `Retry-After: {seconds}` for hard rate limits (if ever needed)

## Caching

### Cache Keys
- Domain-based: `{tool}:{domain}:{section}:{version}`
- TTL: 5 minutes for live scans, longer for static data

### Cache Headers
```
X-Cache: HIT|MISS
X-Cache-TTL: 300
```

### Cache-Aware Rate Limiting
Cached responses SHOULD NOT count against rate limits. Only live scans consume rate limit budget.

## Documentation Endpoint

### /api/docs (or /docs)
Every tool serves API documentation as a JSON response:
```
GET /api/docs → JSON describing all endpoints, parameters, response shapes
```

This doubles as the reference for LLM agents and CLI `--help` output.

## CORS

All API endpoints support CORS:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Content-Type, Accept
Access-Control-Max-Age: 86400
```

## Versioning

No URL-based versioning (no `/v1/`). Breaking changes are rare; when needed:
1. Add new fields alongside old ones
2. Deprecate old fields with a notice period
3. Remove after one major version
