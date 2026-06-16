# .lol Design System — New Tool Checklist

> Copy-paste checklist for onboarding a new .lol tool to the family design system.
> Reference: `DESIGN-SYSTEM.md` for full specs, `CONSTITUTION.md` for principles.

## Setup

- [ ] Add dotai submodule: `git submodule add https://github.com/yokedotlol/dotai.git .ai/base`
- [ ] Create product `.ai/` files: `CONSTITUTION.md`, `INVARIANTS.md`, `STATE.md`, `DECISIONS.md`, `GOTCHAS.md`
- [ ] Verify `.ai/` product files are tracked in git (not gitignored)

## CSS Tokens

- [ ] `:root` defines `--font-mono` (full fallback stack) and `--font-sans`
- [ ] `:root` defines `--radius: 8px` and `--radius-sm: 6px`
- [ ] Dark theme (`:root, [data-theme="dark"]`): all surface, text, border, semantic tokens match canonical
- [ ] Dark theme: `--accent`, `--accent-fg`, `--accent-dim`, `--accent-subtle` set to tool's color
- [ ] Light theme (`[data-theme="light"]`): all tokens match canonical
- [ ] Light theme: accent variants set for light mode
- [ ] Semantic tokens: `--ok`, `--ok-subtle`, `--warn`, `--warn-subtle`, `--err`, `--err-subtle`, `--info`, `--purple`

## Base Styles

- [ ] `html { background: var(--bg) }`
- [ ] `body` has `font-family: var(--font-sans)`, `line-height: 1.6`, `-webkit-font-smoothing: antialiased`, `transition: background .25s, color .25s`
- [ ] `a { color: var(--accent) }` with hover underline
- [ ] `:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px }`

## Page Layout

- [ ] Page wrapper uses `.page` class (not `.container` or other names)
- [ ] `max-width` appropriate for tool complexity (640px narrow, 960px wide)
- [ ] Mobile breakpoint adjusts padding

## Header

- [ ] `.hdr` flex row, `padding: 2rem 0 0`, `align-items: baseline`, `gap: 16px`
- [ ] `.logo` with tool name in `--text`, `.lol` in `<span>` styled `var(--accent)`
- [ ] `.tag` tagline in `--font-mono`, 11px, `--dim`
- [ ] Tagline pattern: `fast, API-first {what it does}` — no italic, no trailing period
- [ ] Mobile: `.hdr` wraps to column

## Terminal Input

- [ ] `.input-wrap` with bottom border `2px solid var(--accent)`, no box/background
- [ ] `outline: none` on `.input-wrap`
- [ ] `.input-wrap :focus-visible, .input-wrap:focus-visible { outline: none }`
- [ ] Prompt: `$ {tool} ▸` in `--accent`, weight 600
- [ ] Input `.di` in `--font-mono`, 14px, transparent bg, `outline: none`
- [ ] Blinking cursor `.cur`: 7px × 14px `--accent` block, `step-end 1.1s`
- [ ] Placeholder uses `--faint`

## Empty State

- [ ] Curl example in monospace
- [ ] `.examples` flex row with clickable domain buttons
- [ ] Buttons use `--surface` bg, `--border`, `--radius-sm`, `--accent` text

## Footer

- [ ] `.footer` centered, `--font-mono`, 10px, `margin-top: 2rem`
- [ ] `.footer a` uses `--dim`, hover → `--muted`
- [ ] `.footer-links` flex row with `gap: 16px` — tool-specific links
- [ ] `.footer-family` flex row with `gap: 16px` — sibling tool links (omit self)
- [ ] `.yoke-badge` with `opacity: 0.6`, hover → `1`
- [ ] Class names: `.footer-links` and `.footer-family` (not `.foot-*`)

## Theme Toggle

- [ ] Segmented control: `<div class="theme-toggle" role="radiogroup">` with `.theme-opt` buttons
- [ ] Fixed `top: 16px; right: 16px`
- [ ] Word-based: "Dark" and "Light" — no emoji
- [ ] Active state: `--accent` background, `--accent-fg` text, weight 600
- [ ] localStorage key: `{tool}-theme`
- [ ] Load order: localStorage → system preference → dark default

## Click-to-Copy

- [ ] All data values wrapped in `.data-val` class
- [ ] Hover: `cursor: pointer`, color → `--accent`
- [ ] Click: copies `textContent.trim()` to clipboard
- [ ] "copied" toast via `::after` pseudo-element, 1.2s timeout
- [ ] `title="Click to copy"` on all `.data-val` elements

## Rate Limit Pill

- [ ] `.rl-pill` fixed `bottom: 16px; right: 16px`, pill shape
- [ ] Shows `remaining/limit` from `X-RateLimit-*` headers
- [ ] Three states: normal (>25%), warning (10-25%), danger (<10%)
- [ ] Expandable detail dropdown on click/hover

## Accessibility

- [ ] `<html lang="en">`
- [ ] `<a href="#main" class="skip-nav">Skip to content</a>` — first element in body
- [ ] Skip-nav: `left: -9999px`, focus → `left: 0`, `z-index: 200`, `color: var(--accent-fg, #fff)`
- [ ] Main content has `id="main"`
- [ ] `.sr-only` utility class defined
- [ ] `aria-label` on `<nav>`, `<form>`, interactive elements

## Cross-Linking (feeder tools only)

- [ ] `.hook` styled link to yoke.lol full report
- [ ] `_meta.full_report` in API JSON responses
- [ ] Standalone tools (vrfy, preflight): NO hook, NO `full_report`

## Infrastructure

- [ ] Security headers on all responses (CSP, HSTS, X-Frame-Options, etc.)
- [ ] Rate limiting with `X-RateLimit-*` headers
- [ ] MTA-STS handler on `mta-sts.{tool}.lol`
- [ ] `/privacy`, `/terms`, `/security.txt`, `/llms.txt`, `/robots.txt`, `/sitemap.xml`
- [ ] JSON-LD `WebApplication` structured data
- [ ] OG meta tags with 1200×630 dark-themed image
