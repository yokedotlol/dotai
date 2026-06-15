# .lol Family Design System

> One design system, one aesthetic, every tool. This spec defines the canonical design tokens, layout patterns, and component styles that all .lol family tools must share. Individual tools can extend (Yoke's 12 themes, score visualizations) but the baseline must be identical.

## Problem

All three shipped tools drift from each other:

| Token | certs.lol | ns.lol | yoke.lol |
|-------|-----------|--------|----------|
| **Background** | `#0a0a0f` | `#0a0e17` | `#0f1419` |
| **Surface** | `#111116` | `#111827` | `#161b22` |
| **Text** | `#d8d8e0` | `#e2e8f0` | `#e6edf3` |
| **Muted** | `#8e8e9a` | `#64748b` | `#7d8590` |
| **Dim** | `#5c5c6b` | `#475569` | `#7d8590` |
| **Accent** | `#9b8afb` (purple) | `#22d3ee` (cyan) | `#58a6ff` (blue) |
| **Success** | `#38d9a9` | `#22c55e` | `#3fb950` |
| **Warning** | `#fbbf24` | `#eab308` | `#d29922` |
| **Error** | `#f87171` | `#ef4444` | `#f85149` |
| **Border** | `#1c1c24` | `#1e293b` | `#21262d` |
| **Font vars** | `--mono`, `--sans` | `--mono`, `--sans` | `--font-mono`, `--font-ui` |
| **Input** | Terminal prompt + underline | Boxed + button | Rounded + glow |
| **Header** | Left, baseline | Centered hero | Left flex row |
| **Footer** | Left, 10px mono | Centered, 0.78rem | Centered, 12px |
| **Theme toggle** | Fixed top-right (light/dark) | None | 12-theme dropdown |
| **Light theme** | ✅ full | ❌ none | ✅ full |

No two sites agree on any of these.

## Design Principles

1. **Dark-mode-first, terminal aesthetic** — the family DNA
2. **Each tool has a signature accent** — that's identity, not drift
3. **Everything else is shared** — backgrounds, surfaces, text, borders, semantic colors, fonts, layout chrome, footer, input treatment
4. **Extend, don't override** — Yoke's 12 themes extend the base; they don't replace it

## Canonical Tokens

### Shared base (every tool)

```css
:root {
  /* ─── Fonts ─────────────────────────── */
  --font-mono: 'JetBrains Mono', ui-monospace, 'Cascadia Code', 'Source Code Pro', Menlo, Consolas, monospace;
  --font-sans: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;

  /* ─── Radii ─────────────────────────── */
  --radius: 8px;
  --radius-sm: 6px;
}
```

### Dark theme (default)

```css
:root, [data-theme="dark"] {
  color-scheme: dark;

  /* ─── Surfaces ──────────────────────── */
  --bg: #0a0a12;
  --surface: #12121a;
  --surface-raised: #1a1a24;
  --surface-hover: #22222e;
  --border: #1e1e2a;
  --border-muted: #16161f;

  /* ─── Text ──────────────────────────── */
  --text: #e0e0ea;
  --text-secondary: #a8a8b8;
  --muted: #7a7a8e;
  --dim: #55556a;
  --faint: #3a3a4a;

  /* ─── Accent (per-tool override) ────── */
  --accent: <tool-specific>;
  --accent-fg: #0a0a12;
  --accent-dim: <tool-specific>;
  --accent-subtle: <tool-specific @ 0.08 alpha>;

  /* ─── Semantic ──────────────────────── */
  --ok: #3fb950;
  --ok-subtle: rgba(63, 185, 80, 0.08);
  --warn: #e5a820;
  --warn-subtle: rgba(229, 168, 32, 0.08);
  --err: #f85149;
  --err-subtle: rgba(248, 81, 73, 0.08);
  --info: #6ea8fe;
  --purple: #bc8cff;
}
```

### Light theme

```css
[data-theme="light"] {
  color-scheme: light;

  --bg: #fafafe;
  --surface: #f0f0f5;
  --surface-raised: #e8e8ef;
  --surface-hover: #dddde6;
  --border: #d0d0dc;
  --border-muted: #e0e0ea;

  --text: #1a1a2e;
  --text-secondary: #4a4a60;
  --muted: #6a6a80;
  --dim: #9090a4;
  --faint: #b8b8c8;

  --accent: <tool-specific-light>;
  --accent-fg: #ffffff;
  --accent-dim: <tool-specific>;
  --accent-subtle: <tool-specific @ 0.06 alpha>;

  --ok: #16a34a;
  --ok-subtle: rgba(22, 163, 74, 0.06);
  --warn: #b58900;
  --warn-subtle: rgba(181, 137, 0, 0.06);
  --err: #dc2626;
  --err-subtle: rgba(220, 38, 38, 0.06);
  --info: #2563eb;
  --purple: #8250df;
}
```

### Per-tool accent colors

Each tool keeps its own accent — this is identity, not drift:

| Tool | Dark accent | Light accent | Personality |
|------|------------|-------------|-------------|
| **yoke.lol** | `#58a6ff` (blue) | `#0969da` | The hub — steady, authoritative |
| **certs.lol** | `#9b8afb` (purple) | `#7c3aed` | Security — distinct, premium |
| **ns.lol** | `#22d3ee` (cyan) | `#0891b2` | DNS — fast, technical |
| **vrfy.lol** | `#f0abfc` (pink/magenta) | `#c026d3` | Email — warm, different |
| **preflight.lol** | `#fb923c` (orange) | `#ea580c` | HTTP — active, urgent |

### Yoke's extended themes

Yoke's 12 themes (arcade, deep-blue, enterprise, etc.) extend the base. Each must:
- Use the canonical `--font-sans` / `--font-mono` var names
- Use the canonical semantic color names (`--ok`, `--warn`, `--err`)
- Provide all surface/text/border tokens from the shared set
- Can override accent and add theme-specific tokens as needed

The theme system is a Yoke differentiator. Other tools get dark + light only.

## Layout Components

### Header

Canonical pattern (all tools):

```
[logo] [tool name]  [mono tagline]              [theme toggle]
```

- Left-aligned, single row, baseline-aligned
- Logo: 24px icon or text treatment
- Tool name: `--font-sans`, 20px, weight 700, `--text`
- Tagline: `--font-mono`, 11-13px, `--dim`
- Divider between name and tagline: 1px `--border` vertical bar
- Theme toggle: right-aligned

Currently:
- **certs.lol**: close but logo uses styled text spans
- **ns.lol**: centered hero layout — needs to go left-aligned
- **yoke.lol**: close already — just needs tagline in mono + consistent sizing

### Search Input

Canonical pattern: **terminal prompt style**

```
[accent prompt] [domain input with monospace] [blinking cursor]
```

- Container: bottom border 2px `--accent`, no box/background
- Prompt: `--accent`, weight 600, `--font-mono`
  - certs: `$ certs ▸`
  - ns: `$ ns ▸`
  - yoke: `$ yoke ▸`
  - vrfy: `$ vrfy ▸`
  - preflight: `$ preflight ▸`
- Input: `--font-mono`, 14px, `--text`, transparent background
- Blinking cursor: 7px × 14px `--accent` block, `step-end 1.1s`

Currently:
- **certs.lol**: ✅ already canonical
- **ns.lol**: boxed input with button — needs terminal prompt treatment
- **yoke.lol**: rounded glow bar — needs terminal prompt treatment

**Note for Yoke:** The search bar currently supports a compare toggle and scan button. These can remain as inline elements after the prompt, but the visual base should match the terminal style.

### Footer

Canonical pattern:

```
[links · separated · by · dots]  [yoke badge]
```

- Font: `--font-mono`, 10-11px, `--faint`/`--dim`
- Links: `--dim`, hover → `--muted`
- Dot separator: `--border`
- Standard links (all tools): `docs · github · privacy · terms · security.txt`
- Tool-specific links as needed (CLI, API, extension, feedback)
- Family links section: links to sibling tools
- Yoke badge: right side, linked to `yoke.lol/{hostname}`
- Left-aligned or centered — either is fine, but all tools must match

Currently:
- **certs.lol**: left-aligned, close to canonical
- **ns.lol**: centered, family section, close
- **yoke.lol**: centered, verbose, larger font

Choose one alignment and apply everywhere. Recommendation: **centered** — it works better on narrow screens and all tools should have a family links row.

### Family Links

Every tool includes a "family" row in the footer linking to siblings:

```html
<div class="family">
  <a href="https://yoke.lol">yoke</a>
  <a href="https://certs.lol">certs</a>
  <a href="https://ns.lol">ns</a>
  <!-- current tool omitted from its own footer -->
</div>
```

Styled as small bordered pills (ns.lol's current `.family` class). All tools use this.

### Theme Toggle

All tools get at minimum a light/dark toggle in the top-right corner:
- Button: `--surface` bg, `--border` border, `--font-mono` 11px
- Shows ☀️/🌙 icon
- Position: fixed top-right (16px inset)

Yoke additionally has its 12-theme dropdown — that extends rather than replaces. On Yoke, the toggle opens the full theme menu. On other tools, it's a simple click to swap.

### Accessibility Baseline

All tools must include:
- `<html lang="en">`
- Skip-nav link (`<a href="#main" class="skip-nav">Skip to content</a>`)
- `.sr-only` utility class
- `aria-label` on nav, search, and interactive elements
- Focus indicators on all interactive elements
- Color contrast meeting WCAG AA on text/bg combinations

## Shared CSS Skeleton

Reference implementation — each tool copies and extends:

```css
/* ─── Base ─────────────────────────── */
html { background: var(--bg) }
body {
  background: var(--bg);
  color: var(--text);
  font-family: var(--font-sans);
  -webkit-font-smoothing: antialiased;
  line-height: 1.6;
  transition: background .25s, color .25s;
}
a { color: var(--accent); text-decoration: none }
a:hover { text-decoration: underline }

/* ─── Header ───────────────────────── */
.hdr {
  padding: 2rem 0 0;
  display: flex;
  align-items: baseline;
  gap: 16px;
}
.logo {
  font-size: 1.25rem;
  font-weight: 800;
  letter-spacing: -0.04em;
  text-decoration: none;
  color: var(--text);
}
.logo .accent { color: var(--accent) }
.tagline {
  font-size: 11px;
  color: var(--dim);
  font-family: var(--font-mono);
}

/* ─── Terminal input ───────────────── */
.input-wrap {
  margin-top: 2rem;
  border-bottom: 2px solid var(--accent);
  padding-bottom: 10px;
  font-family: var(--font-mono);
  font-size: 14px;
  display: flex;
  align-items: center;
  transition: border-color .25s;
}
.prompt { color: var(--accent); font-weight: 600; margin-right: 10px }
.domain-input {
  background: none;
  border: none;
  color: var(--text);
  font-family: var(--font-mono);
  font-size: 14px;
  outline: none;
  flex: 1;
  caret-color: var(--accent);
}
.domain-input::placeholder { color: var(--faint) }
.cursor {
  display: inline-block;
  width: 7px;
  height: 14px;
  background: var(--accent);
  animation: blink 1.1s step-end infinite;
  vertical-align: text-bottom;
}
@keyframes blink { 50% { opacity: 0 } }

/* ─── Footer ───────────────────────── */
.footer {
  padding: 2rem 0 3rem;
  margin-top: 2rem;
  text-align: center;
  font-size: 10px;
  color: var(--faint);
  font-family: var(--font-mono);
}
.footer a { color: var(--dim); text-decoration: none }
.footer a:hover { color: var(--muted) }
.footer-links {
  display: flex;
  gap: 1.5rem;
  justify-content: center;
  flex-wrap: wrap;
  margin-bottom: 12px;
}
.family {
  display: flex;
  gap: 12px;
  justify-content: center;
  margin-bottom: 12px;
}
.family a {
  padding: 3px 10px;
  border: 1px solid var(--border);
  border-radius: 4px;
  font-size: 10px;
  color: var(--dim);
  transition: color .2s, border-color .2s;
}
.family a:hover { color: var(--accent); border-color: var(--accent) }

/* ─── Theme toggle ─────────────────── */
.theme-toggle {
  position: fixed;
  top: 16px;
  right: 16px;
  background: var(--surface);
  color: var(--muted);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 6px 12px;
  cursor: pointer;
  font-family: var(--font-mono);
  font-size: 11px;
  z-index: 100;
  transition: all .2s;
}
.theme-toggle:hover { color: var(--text); border-color: var(--accent) }

/* ─── Accessibility ────────────────── */
.skip-nav {
  position: absolute;
  left: -9999px;
  top: 0;
  z-index: 200;
  padding: 8px 16px;
  background: var(--accent);
  color: #fff;
  font-family: var(--font-mono);
  font-size: 12px;
  text-decoration: none;
  border-radius: 0 0 4px 0;
}
.skip-nav:focus { left: 0 }
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0,0,0,0);
  white-space: nowrap;
  border: 0;
}
```

## Per-Tool Change Map

### yoke.lol (largest change — React SPA + Tailwind)

**CSS tokens (theme.css):**
- Rename `--font-mono` → keep as-is OR alias both (Tailwind references `--font-mono`)
- Add `--font-sans` alias for `--font-ui`
- Align dark base: `--bg: #0a0a12`, `--surface: #12121a`, `--border: #1e1e2a`
- Align semantic: `--ok`/`--warn`/`--err` aliases alongside existing names
- Align text: `--text: #e0e0ea`, `--muted: #7a7a8e`, `--dim: #55556a`
- Add `--faint` token
- Light theme: align to canonical light palette
- All 12 extended themes: update to use canonical token names

**Header (App.tsx):**
- Add mono tagline after logo
- Align sizing/spacing to canonical pattern
- Keep ThemeToggle component as-is (it's well-built)

**Search input (App.tsx):**
- Replace rounded glow bar with terminal prompt style
- Add `$ yoke ▸` prompt prefix
- Keep compare toggle + scan button as inline addons
- Blinking cursor when idle

**Footer (App.tsx):**
- Switch to `--font-mono`, 10-11px
- Add family links row (certs.lol, ns.lol)
- Slim down link set
- Match canonical centered layout

**Accessibility:**
- Add skip-nav link
- Add `.sr-only` utility
- Verify `lang="en"` on HTML

**Preserved (no changes):**
- 12-theme system ✅
- Masonry panel grid ✅
- DomainScore / scorecards / badges ✅
- PDF reports ✅
- Share cards / OG images ✅
- Tab system ✅
- Compare view ✅
- All panel components ✅
- SSE streaming ✅
- CLI page, docs, API docs ✅

### certs.lol (smallest change — vanilla SPA)

**CSS tokens:**
- Rename `--sans` → `--font-sans`, `--mono` → `--font-mono`
- Align base colors to canonical (minor shifts from `#0a0a0f` → `#0a0a12`, etc.)
- Add missing tokens: `--surface-raised`, `--surface-hover`, `--text-secondary`, `--faint`
- Rename `--ok`/`--hi`/`--warn`/`--err` → keep `--ok`/`--warn`/`--err`, add `--info`

**Light theme:**
- Align to canonical light palette

**Footer:**
- Add family links row (yoke.lol, ns.lol)
- Centered layout to match canonical

**Accessibility:**
- Already has skip-nav ✅
- Verify all ARIA labels

### ns.lol (medium change — vanilla SPA)

**CSS tokens:**
- Rename vars to canonical names
- Align base colors from Tailwind-ish palette to canonical
- Add light theme (currently dark only)
- Add `--faint`, `--text-secondary`, `--surface-raised`, `--surface-hover`

**Header:**
- Switch from centered hero to left-aligned canonical header
- Logo + "ns" + mono tagline inline

**Search input:**
- Replace boxed input + button with terminal prompt style
- `$ ns ▸` prompt prefix

**Footer:**
- Already has family links ✅
- Align font/size to canonical (10px mono)
- Match centered canonical layout

**Theme toggle:**
- Add light/dark toggle (currently missing)

**Accessibility:**
- Add skip-nav link
- Add `lang="en"`
- Add `.sr-only`

## Execution Order

1. **Establish canonical** — write the shared CSS as a reference file
2. **ns.lol first** — smallest codebase, already wrapping up, good proving ground
3. **certs.lol second** — small changes, validate the tokens
4. **yoke.lol last** — largest change, most complex, benefits from lessons in 2+3

## Non-Goals

- Shared CSS build pipeline / npm package (premature — copy-paste the tokens)
- Changing Yoke's architecture (React, Tailwind, component structure stays)
- Changing any tool's feature set or functionality
- Removing Yoke's 12 themes
- Making the tools visually identical — they share chrome but have different complexity
