# .ai — Shared Context Framework for the .lol Family

> Base-layer conventions for AI agents working on any .lol tool.  
> Include as a git submodule at `.ai/base/` in each product repo.

## Structure

```
CONSTITUTION.md     — Philosophy, principles, brand DNA
DESIGN-SYSTEM.md    — Canonical tokens, layout, components
CLI-UX.md           — CLI distribution, output formatting, install patterns
API-CONVENTIONS.md  — Endpoint patterns, errors, content negotiation, PoW
INFRA.md            — CF Workers, Fly probes, DNS, email, caching, security headers
FUNNEL.md           — Cross-linking rules, Yoke badges, family relationships
INVARIANTS.md       — Shared invariants that apply to every tool
PROBES.md           — Probe architecture, multi-region, User-Agent strategy
```

## Usage

Each product repo includes this as a submodule:

```bash
git submodule add https://github.com/yokedotlol/dotai .ai/base
```

Product-specific overrides live alongside:

```
.ai/
  base/              ← this submodule
  STATE.md           — What's deployed, what's in progress
  DECISIONS.md       — Product-specific architectural choices
  GOTCHAS.md         — Product-specific pitfalls
  INVARIANTS.md      — Extends shared (e.g. "Yoke has 12 themes")
```

Agent pattern: read `.ai/base/*` for family context, then `.ai/*.md` for product overrides.
