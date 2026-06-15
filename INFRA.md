# INFRA.md — Infrastructure Standards

## Cloudflare Workers

### Deployment
- Each tool is a single CF Worker on the $5/mo Paid plan.
- Deploy via GitHub Actions: `wrangler deploy` with scoped `CF_API_TOKEN`.
- Token must have: `Workers Scripts:Edit`, `Workers Routes:Edit`, `Workers KV Storage:Edit` (if KV used), `D1:Edit` (if D1 used).
- Worker route: `{tool}.lol/*` on the tool's zone.

### Security Headers

Every response MUST include:

```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=(), interest-cohort=()
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self'; font-src 'self' https://fonts.gstatic.com; frame-ancestors 'none'
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-XSS-Protection: 0
```

**CSP notes:**
- `'unsafe-inline'` for styles is acceptable when inline styles are used in the SPA. Work toward nonce-based when feasible.
- `script-src` MUST NOT include `'unsafe-inline'` or `'unsafe-eval'`.
- Tighten `connect-src` to specific API origins where possible.

### Caching Headers

For API JSON responses:
```
Cache-Control: public, max-age=300, s-maxage=300, stale-while-revalidate=60
Vary: Accept, Accept-Encoding
```

For static assets (CSS/JS/fonts):
```
Cache-Control: public, max-age=31536000, immutable
```

For HTML pages:
```
Cache-Control: public, max-age=3600, s-maxage=3600, stale-while-revalidate=300
```

For OG images / share cards:
```
Cache-Control: public, max-age=86400, s-maxage=86400
```

### CORS

API endpoints should include:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Content-Type, Accept
Access-Control-Max-Age: 86400
```

## DNS Setup

Every .lol domain MUST have:

### Email (via Cloudflare Email Routing)
```
MX   @  → route1.mx.cloudflare.net     (priority 36)
MX   @  → route2.mx.cloudflare.net     (priority 4)
MX   @  → route3.mx.cloudflare.net     (priority 94)
SPF  @  → v=spf1 include:_spf.mx.cloudflare.net -all
DMARC @  → v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; rua=mailto:hello@{tool}.lol
```

### DKIM
Publish CF Email Routing DKIM keys. Check the CF dashboard → Email Routing → DKIM for the specific records. Two records typically needed:
- `cf2024-1._domainkey.{tool}.lol` — signing key
- `cf-bounce._domainkey.{tool}.lol` — bounce handling

### MTA-STS
Serve `_mta-sts.{tool}.lol` TXT record:
```
v=STSv1; id={timestamp}
```

Serve MTA-STS policy at `https://mta-sts.{tool}.lol/.well-known/mta-sts.txt`:
```
version: STSv1
mode: enforce
mx: route1.mx.cloudflare.net
mx: route2.mx.cloudflare.net
mx: route3.mx.cloudflare.net
max_age: 604800
```

This requires a Worker route on `mta-sts.{tool}.lol/*`.

### TLS Reporting
```
_smtp._tls.{tool}.lol TXT "v=TLSRPTv1; rua=mailto:hello@{tool}.lol"
```

### CAA
```
CAA 0 issue "letsencrypt.org"
CAA 0 issue "digicert.com"
CAA 0 issue "pki.goog"
CAA 0 iodef "mailto:hello@{tool}.lol"
```

### DNSSEC
Enable via Cloudflare dashboard. Non-negotiable.

### BIMI
Optional. Only add if the tool has a published SVG logo that meets BIMI requirements. Currently: none of the tools have BIMI.

### Email Grade Target
Following all the above should yield an **A** on Yoke's email axis. The checklist:
- ✅ MX records present
- ✅ SPF with `-all` (hard fail)
- ✅ DMARC with `p=reject`
- ✅ DKIM published
- ✅ MTA-STS in enforce mode
- ✅ TLS reporting configured
- ✅ CAA records present

## Static Pages

Every tool MUST serve:

### /privacy
Privacy policy. Template:
- No cookies, no tracking, no analytics beyond CF Analytics
- No personal data stored (or describe what IS stored)
- No third-party data sharing
- GDPR/CCPA: nothing to delete because nothing is stored

### /terms
Terms of service. Template:
- Service provided as-is, no warranty
- Rate limiting and PoW for abuse prevention
- Don't use for illegal purposes

### /security.txt (/.well-known/security.txt)
```
Contact: https://github.com/yokedotlol/{repo}/issues
Expires: {one year from now}
Preferred-Languages: en
Canonical: https://{tool}.lol/.well-known/security.txt
```
**Contact is GitHub Issues, NOT email.**

### /llms.txt
Machine-readable description for LLM agents:
- Tool name and purpose
- API endpoints
- Links to docs and family sites

### /robots.txt
```
User-agent: *
Allow: /

Sitemap: https://{tool}.lol/sitemap.xml
```

### /sitemap.xml
Standard XML sitemap with all public pages.

### /.well-known/security.txt
Same as /security.txt (serve from both paths).

## SEO / Structured Data

### JSON-LD
Every tool MUST include `WebApplication` schema.org markup:
```json
{
  "@context": "https://schema.org",
  "@type": "WebApplication",
  "name": "{Tool Name}",
  "url": "https://{tool}.lol",
  "description": "{one-line description}",
  "applicationCategory": "DeveloperApplication",
  "operatingSystem": "Any",
  "offers": { "@type": "Offer", "price": "0", "priceCurrency": "USD" }
}
```

### OG Tags
Every tool MUST have:
```html
<meta property="og:title" content="{Tool} — {tagline}">
<meta property="og:description" content="{description}">
<meta property="og:image" content="https://{tool}.lol/og.png">
<meta property="og:url" content="https://{tool}.lol">
<meta property="og:type" content="website">
<meta name="twitter:card" content="summary_large_image">
```

The OG image (1200×630) should use the dark terminal aesthetic with the tool's accent color.

## GitHub Actions CI

Standard workflow:
```yaml
name: CI + Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npx tsc --noEmit        # typecheck
      - run: npm test                 # vitest (if tests exist)
      - run: npm run build            # build client (if SPA)
      - run: npx wrangler deploy      # deploy Worker
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CF_API_TOKEN }}
```

Secrets needed:
- `CF_API_TOKEN` — scoped token with Workers + KV + D1 permissions
- `CF_ACCOUNT_ID` — account identifier
- Any tool-specific secrets (e.g. `PROBE_KEY`)
