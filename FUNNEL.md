# FUNNEL.md — Cross-Linking & Family Relationships

## The Funnel

```
certs.lol ──→ yoke.lol
ns.lol    ──→ yoke.lol
vrfy.lol       (standalone — no funnel to yoke)
preflight.lol  (standalone — no funnel to yoke)
```

**Yoke is the hub.** certs.lol and ns.lol are feeder tools that link users to Yoke for the full picture. vrfy.lol and preflight.lol are standalone — they do NOT funnel to Yoke.

## Cross-Linking Rules

### certs.lol → yoke.lol
- Every scan result includes: `→ Full domain report on yoke.lol →`
- API JSON includes `_meta.full_report: "https://yoke.lol/{domain}"`
- Yoke never links back to certs.lol or mentions it

### ns.lol → yoke.lol
- Results page includes cross-link buttons: `🔒 TLS Report` (→ certs.lol) and `📊 Full Analysis` (→ yoke.lol)
- API JSON includes `_meta.full_report: "https://yoke.lol/{domain}"`
- Yoke never links back

### vrfy.lol (standalone)
- No links to Yoke in results or API
- No `_meta.full_report` field
- May link to certs.lol or ns.lol for DNS/TLS context of the mail server, but this is informational, not a funnel

### preflight.lol (standalone)
- No links to Yoke in results or API
- May link to certs.lol for TLS details (`TLS version: ... → deep dive on certs.lol`)
- May link to ns.lol for DNS context
- These are informational cross-references, not funnels

## Yoke Badges

Every .lol tool displays a Yoke score badge in its footer:

```html
<a href="https://yoke.lol/{hostname}">
  <img src="https://yoke.lol/badge/{hostname}.svg" 
       alt="Yoke score for {hostname}" 
       height="20">
</a>
```

This is a quality signal — "we eat our own dog food." The badge links to the tool's own Yoke report.

## Footer Family Links

Every tool includes a family links section in its footer linking to siblings. The current tool is omitted from its own list:

```html
<div class="family">
  <!-- omit the current tool -->
  <a href="https://yoke.lol">yoke</a>
  <a href="https://certs.lol">certs</a>
  <a href="https://ns.lol">ns</a>
</div>
```

When vrfy.lol and preflight.lol launch, add them to the family links across all tools.

## API Cross-References

For feeder tools (certs.lol, ns.lol), every API response includes:

```json
{
  "_meta": {
    "tool": "certs.lol",
    "version": "1.0",
    "scanned_at": "2026-06-15T21:00:00Z",
    "full_report": "https://yoke.lol/{domain}",
    "family": {
      "dns": "https://ns.lol/{domain}",
      "tls": "https://certs.lol/{domain}",
      "score": "https://yoke.lol/{domain}"
    }
  }
}
```

For standalone tools (vrfy.lol, preflight.lol), `full_report` is omitted:

```json
{
  "_meta": {
    "tool": "vrfy.lol",
    "version": "1.0",
    "scanned_at": "2026-06-15T21:00:00Z"
  }
}
```
