# INVARIANTS.md — Shared Invariants

Rules that apply across every .lol tool. Product-specific invariants extend these in `.ai/INVARIANTS.md`.

## Non-Negotiable

1. **No accounts.** No signup, no login, no user database.
2. **No API keys for basic use.** PoW is the rate limiter.
3. **No cookies.** No tracking, no session state.
4. **$5/mo CF Workers.** If a tool costs more, justify it.
5. **HTTPS only.** HSTS preload on every domain.
6. **DNSSEC enabled.** On every domain.
7. **SPF hard fail (`-all`).** Not `~all`.
8. **DMARC reject.** `p=reject; sp=reject`.
9. **CAA records present.** Restrict CA issuance.
10. **security.txt Contact = GitHub Issues.** Not email.

## Design

11. **Inter + JetBrains Mono.** No other fonts.
12. **Dark-mode-first.** Light theme available but dark is default.
13. **Terminal prompt input.** `$ {tool} ▸ {domain}_` — not a search box.
14. **Yoke badge in footer.** Every tool, linked to its own Yoke report.
15. **Family links in footer.** Link to all sibling tools.
16. **Canonical CSS token names.** See DESIGN-SYSTEM.md.

## API

17. **`GET /{domain}` is the primary endpoint.** One curl, full result.
18. **JSON by default for API clients.** Content negotiation via `Accept` header.
19. **`_meta` block in every response.** Tool name, version, timestamp.
20. **Feeder tools include `_meta.full_report`.** Links to yoke.lol/{domain}.
21. **Standalone tools (vrfy) do NOT include `full_report`.** xhttp includes `_meta.links` with cross-references but is not a feeder tool.
22. **HTTP status codes are meaningful.** 200=ok, 400=bad input, 429=rate limit, 502=upstream error.

## Infrastructure

23. **GitHub Actions for CI/CD.** Typecheck → test → build → deploy.
24. **Scoped CF API tokens.** Minimum necessary permissions per tool.
25. **No secrets in git history.** Ever. Use git-filter-repo if found.
26. **`.ai/` work product files in `.gitignore`.** Don't ship to public repos.
27. **Fly probes use auth.** Bearer token or query key. No open endpoints.

## Legal

28. **Privacy page required.** `/privacy` on every tool.
29. **Terms page required.** `/terms` on every tool.
30. **CC BY 4.0 attribution where required.** (HIBP data, etc.)

## Documentation

31. **Feature ships → docs update in same commit.** When a user-facing feature changes (new command, renamed field, new endpoint, scoring change), every surface that documents or demonstrates it must be updated atomically. Stale docs are bugs, not tech debt.
32. **Sample output matches current behavior.** Axis names, tier labels, terminal output, command signatures in docs must reflect what the tool actually produces. No old terminology, no outdated screenshots.
