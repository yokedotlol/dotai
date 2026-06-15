# CONSTITUTION.md — .lol Family DNA

## What We Are

Developer tools that respect developers. Each tool does one thing well, gives you the answer fast, and gets out of the way.

## Core Principles

### No Accounts, No Tracking
- No signups. No API keys for basic use.
- No analytics beyond CF Analytics (privacy-preserving, no cookies).
- Proof of Work for abuse prevention — computational cost, not bureaucratic friction.

### API-First
- Every tool works from `curl`. The SPA is a nice frontend, not the product.
- `curl -s https://{tool}.lol/{domain} | jq` is the canonical interface.
- Content negotiation: browsers get HTML, API clients get JSON.
- `Accept: application/json` always returns structured data.

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

## Brand DNA

### Name Philosophy
- "A yoke is for those who pull the load" — support teams, consultants, freelancers.
- ".lol" is a nod to teams that name internal tools things like "trogdor" or "WOPR."
- Each tool has a short, memorable, lowercase name.

### Design DNA
- Inter (sans) + JetBrains Mono (mono)
- Dark-mode-first, terminal/hacker aesthetic
- curl-first UX — the tool should feel like a CLI that happens to have a web UI
- Each tool has a signature accent color (see DESIGN-SYSTEM.md)

### Voice
- Direct, technical, no marketing fluff
- "Fast, API-first DNS toolkit" not "Revolutionize your DNS workflow"
- Error messages explain what happened and how to fix it
- Docs are reference, not tutorials
