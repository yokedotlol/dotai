# .lol Family Design System

> One design system, one aesthetic, every tool. This spec defines the canonical design tokens, layout patterns, and component styles that all .lol family tools must share. Individual tools can extend (Yoke's 12 themes, score visualizations) but the baseline must be identical.

## Status

Aligned across certs.lol and ns.lol as of 2026-06-15. Yoke.lol still uses its own design language (React + Tailwind) and needs migration.

## Design Principles

1. **Dark-mode-first, terminal aesthetic** — the family DNA
2. **Each tool has a signature accent** — that's identity, not drift
3. **Everything else is shared** — backgrounds, surfaces, text, borders, semantic colors, fonts, layout chrome, footer, input treatment
4. **Extend, don't override** — Yoke's 12 themes extend the base; they don't replace it
5. **Click-to-copy everywhere** — every data value a user might want to grab (DNS records, IPs, headers, scores, cert details) is clickable to copy. Hover shows `cursor: pointer` with accent highlight; click copies to clipboard and shows a brief "copied" confirmation. This is the family's core interaction pattern — output exists to be used, not just read

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
  --surface: #15151f;
  --surface-raised: #1e1e2a;
  --surface-hover: #26263a;
  --border: #2a2a3a;
  --border-muted: #1e1e2a;

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
| **xhttp.lol** | `#fb923c` (orange) | `#ea580c` | HTTP — active, urgent |

### Yoke's extended themes

Yoke's 12 themes (arcade, deep-blue, enterprise, etc.) extend the base. Each must:
- Use the canonical `--font-sans` / `--font-mono` var names
- Use the canonical semantic color names (`--ok`, `--warn`, `--err`)
- Provide all surface/text/border tokens from the shared set
- Can override accent and add theme-specific tokens as needed

The theme system is a Yoke differentiator. Other tools get dark + light only.

## Layout Components

### Page Wrapper

```css
.page {
  max-width: <tool-specific>;   /* 640px for certs, 960px for ns, etc. */
  margin: 0 auto;
  padding: 0 1.5rem;
}
```

The class name MUST be `.page` on all tools. Max-width varies by content complexity — narrow tools (certs) use 640px, wider tools (ns) use 960px.

Mobile override: `padding: 0 1rem` at the tool's mobile breakpoint.

### Header

```
[logo][.lol]  [mono tagline]                    [theme toggle]
```

- Left-aligned flex row, baseline-aligned
- Logo: styled text — tool name in `--text`, `.lol` span in `--accent`
- Font: `--font-sans` via `.logo` class (inherits weight 800, letter-spacing -0.04em)
- Tagline: `.tag` class, `--font-mono`, 11px, `--dim`
- Pattern: `fast, API-first {what it does}` — no italic, no trailing period
- Padding: `2rem 0 0`

```css
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
.logo span { color: var(--accent) }
.tag {
  font-size: 11px;
  color: var(--dim);
  font-family: var(--font-mono);
}
```

Mobile (`@media(max-width:520px)`):
```css
.hdr { flex-direction: column; gap: 4px; padding-top: 2rem }
```

### Terminal Input

The signature UX across the whole family.

```
$ {tool} ▸ domain.com_
```

- Container: bottom border 2px `--accent`, no box/background
- Prompt elements: `$` + command name in `--accent`, weight 600
- Chevron `▸` in `--dim`
- Input: `--font-mono`, 14px, `--text`, transparent background
- Blinking cursor: 7px × 14px `--accent` block, `step-end 1.1s`
- Container has `outline: none` (bottom border serves as focus indicator)

```css
.input-wrap {
  margin-top: 2rem;
  border-bottom: 2px solid var(--accent);
  padding-bottom: 10px;
  font-family: var(--font-mono);
  font-size: 14px;
  display: flex;
  align-items: center;
  transition: border-color .25s;
  outline: none;
}
.input-wrap form { display: contents }
.p { color: var(--accent); font-weight: 600; margin-right: 10px }
.cm { color: var(--accent); font-weight: 600 }
.dm { color: var(--dim) }
.di {
  background: none;
  border: none;
  color: var(--text);
  font-family: var(--font-mono);
  font-size: 14px;
  outline: none;
  flex: 1;
  min-width: 80px;
  caret-color: var(--accent);
}
.di::placeholder { color: var(--faint) }
.cur {
  display: inline-block;
  width: 7px;
  height: 14px;
  background: var(--accent);
  animation: b 1.1s step-end infinite;
  vertical-align: text-bottom;
  margin-left: 1px;
}
@keyframes b { 0%, 100% { opacity: .7 } 50% { opacity: 0 } }
```

### Empty State / Homepage

When no domain is entered, show a minimal homepage:

```
[curl example in monospace]
[3 clickable example domain buttons]
```

```css
.examples {
  display: flex;
  gap: 8px;
  justify-content: center;
  margin-top: 20px;
  flex-wrap: wrap;
}
.examples a {
  padding: 6px 14px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  font-family: var(--font-mono);
  font-size: 0.82rem;
  color: var(--accent);
  text-decoration: none;
  transition: background .2s;
}
.examples a:hover {
  background: var(--surface-raised);
  text-decoration: none;
}
```

No marketing copy. The curl example IS the pitch.

### Footer

Canonical layout — three rows, centered, flex column with `gap: 10px`:

```
cli · docs · github · privacy · terms          ← tool links
yoke · certs · ns                              ← family links (omit current tool)
[yoke badge]                                   ← score badge
```

```css
.footer {
  padding: 2rem 0 3rem;
  margin-top: 2rem;
  text-align: center;
  font-size: 10px;
  color: var(--faint);
  font-family: var(--font-mono);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}
.footer a { color: var(--dim); text-decoration: none; transition: color .2s }
.footer a:hover { color: var(--muted); text-decoration: none }
.footer-links {
  display: flex;
  justify-content: center;
  gap: 16px;
  flex-wrap: wrap;
}
.footer-family {
  display: flex;
  justify-content: center;
  gap: 16px;
}
.footer-family a { color: var(--faint) }
.footer-family a:hover { color: var(--accent) }
.yoke-badge { display: inline-block }
.yoke-badge img { opacity: 0.6; transition: opacity .2s; vertical-align: middle }
.yoke-badge:hover img { opacity: 1 }
```

**Class names:** `.footer-links` and `.footer-family` (NOT `.foot-links` / `.foot-family`).

### Click-to-Copy Data Values

Every data value a user might want to grab is copyable on click. This applies to all tools — DNS records, IPs, cert details, scores, headers, etc.

```css
.data-val {
  cursor: pointer;
  position: relative;
  transition: color .15s;
}
.data-val:hover { color: var(--accent) }
.data-val::after {
  content: 'copied';
  position: absolute;
  right: 0;
  top: -18px;
  font-size: 9px;
  color: var(--ok);
  background: var(--surface-raised);
  padding: 1px 6px;
  border-radius: 4px;
  opacity: 0;
  transition: opacity .2s;
  pointer-events: none;
}
.data-val.copied::after { opacity: 1 }
```

JS pattern (add to all tools):
```js
document.querySelectorAll('.data-val').forEach(el => {
  el.title = 'Click to copy';
  el.addEventListener('click', function() {
    navigator.clipboard.writeText(this.textContent.trim()).then(() => {
      this.classList.add('copied');
      setTimeout(() => this.classList.remove('copied'), 1200);
    });
  });
});
```

The class name `.data-val` is canonical. Tools can extend with additional copyable elements but must use this base pattern.

### Cross-Link Hook

For feeder tools (certs → yoke, ns → yoke), a styled link to the full report:

```css
.hook {
  margin-top: 2.25rem;
  padding: 14px 0;
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: baseline;
  gap: 10px;
  font-family: var(--font-mono);
  font-size: 12px;
}
.hook .ar { color: var(--accent); font-size: 14px }
.hook .q { color: var(--muted) }
.hook a { color: var(--accent); text-decoration: none; font-weight: 500 }
.hook a:hover { text-decoration: underline }
```

### Theme Toggle

All tools get a light/dark toggle fixed in the top-right corner, using **words not emoji**:

```html
<div class="theme-toggle" role="radiogroup" aria-label="Theme">
  <button class="theme-opt active" role="radio" aria-checked="true">Dark</button>
  <button class="theme-opt" role="radio" aria-checked="false">Light</button>
</div>
```

- Segmented control: two buttons, active state gets `--accent` background
- Labels are "Dark" and "Light" — no emoji (☀️/🌙)
- localStorage key: `{tool}-theme` (e.g. `certs-theme`, `ns-theme`)
- On load: check localStorage → system preference → default dark

```css
.theme-toggle {
  position: fixed;
  top: 16px;
  right: 16px;
  z-index: 100;
  display: flex;
  border-radius: var(--radius-sm);
  overflow: hidden;
  border: 1px solid var(--border);
  background: var(--surface);
  font-family: var(--font-mono);
  font-size: 11px;
}
.theme-opt {
  padding: 5px 10px;
  cursor: pointer;
  border: none;
  background: none;
  color: var(--dim);
  transition: all .15s;
  white-space: nowrap;
}
.theme-opt.active {
  background: var(--accent);
  color: var(--accent-fg);
  font-weight: 600;
}
.theme-opt:not(.active):hover { color: var(--text) }
```

Yoke additionally has its 12-theme dropdown — that extends rather than replaces.

### Rate Limit Pill

Every tool shows a rate limit pill when the API returns `X-RateLimit-*` headers.

**Position:** fixed bottom-right, 16px inset. Pill shape.

**States:**
| State   | Condition              | Appearance |
|---------|------------------------|------------|
| Normal  | >25% remaining         | `--dim`, `--border`, `opacity: 0.7` |
| Warning | 10–25% remaining       | `--warn`, `border-color: --warn`, `opacity: 1` |
| Danger  | <10% or exhausted      | `--err`, `border-color: --err`, `opacity: 1` |

**Expanded details:** hover/click opens a dropdown card showing usage bar + reset time.

```css
.rl-pill {
  position: fixed;
  bottom: 16px;
  right: 16px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 20px;
  padding: 6px 14px;
  font-family: var(--font-mono);
  font-size: 11px;
  color: var(--dim);
  z-index: 100;
  cursor: pointer;
  opacity: 0.7;
  transition: opacity 0.3s, color 0.3s, border-color 0.3s;
}
.rl-pill.warn { color: var(--warn); border-color: var(--warn); opacity: 1 }
.rl-pill.danger { color: var(--err); border-color: var(--err); opacity: 1 }
.rl-detail {
  display: none;
  position: fixed;
  bottom: 48px;
  right: 16px;
  background: var(--surface-raised);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 10px 14px;
  min-width: 220px;
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--text);
  z-index: 101;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.6);
}
.rl-detail.visible { display: block }
```

## Accessibility Baseline

All tools must include:

### Required elements
- `<html lang="en">`
- Skip-nav link: `<a href="#main" class="skip-nav">Skip to content</a>`
- `.sr-only` utility class
- `aria-label` on `<nav>`, `<form>`, and interactive elements
- `:focus-visible` global indicator: `outline: 2px solid var(--accent); outline-offset: 2px`
- WCAG AA color contrast on all text/bg combinations

### Skip-nav CSS
```css
.skip-nav {
  position: absolute;
  left: -9999px;
  top: 0;
  z-index: 200;
  padding: 8px 16px;
  background: var(--accent);
  color: var(--accent-fg, #fff);
  font-family: var(--font-mono);
  font-size: 12px;
  text-decoration: none;
  border-radius: 0 0 6px 0;
}
.skip-nav:focus { left: 0 }
```

### Screen reader utility
```css
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

## Body & Base Styles

```css
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
:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px }
```

## Per-Tool Alignment Status

### certs.lol ✅ (aligned 2026-06-15)
- Canonical tokens ✅
- Light + dark theme ✅
- Terminal prompt input ✅
- Centered footer with family links ✅
- Theme toggle ⚠️ (still emoji — needs word-based update)
- Click-to-copy on data values ✅
- Skip-nav ✅
- `:focus-visible` ✅
- Rate limit pill ✅

### ns.lol ✅ (aligned 2026-06-15)
- Canonical tokens ✅
- Light + dark theme ✅
- Terminal prompt input ✅
- Centered footer with family links ✅
- Theme toggle ⚠️ (still emoji — needs word-based update)
- Click-to-copy on data values ✅
- Skip-nav ✅
- `:focus-visible` ✅
- Rate limit pill ✅
- Wider `.page` (960px) — appropriate for propagation maps and resolver grids

### yoke.lol ⏳ (not yet aligned)
Largest change — React SPA + Tailwind.

**Needs:**
- Align dark base tokens: `--bg: #0a0a12`, `--surface: #12121a`, `--border: #1e1e2a`, etc.
- Align text tokens: `--text: #e0e0ea`, `--muted: #7a7a8e`, `--dim: #55556a`, add `--faint`
- Align semantic colors: `--ok`/`--warn`/`--err` to canonical values
- Add `--font-sans` alias for `--font-ui`
- Terminal prompt input (replace rounded glow bar)
- Mono tagline in header
- Footer: switch to `--font-mono` 10-11px, add family links, slim down
- Skip-nav link
- All 12 extended themes: update to use canonical token names

**Preserved (no changes):**
- 12-theme system, masonry panel grid, score visualizations, PDF reports, share cards/OG images, tab system, compare view, SSE streaming, CLI/docs pages

### vrfy.lol ⏳ (deployed, not yet aligned)
Deployed and working. Has its own SPA. Needs alignment pass for canonical design tokens. Pink/magenta accent.

### xhttp.lol ⏳ (deployed, not yet aligned)
Deployed and working. SPA built into Worker response. Needs alignment pass for canonical design tokens. Orange accent. Formerly preflight.lol.

## Non-Goals

- Shared CSS build pipeline / npm package (premature — copy-paste the tokens)
- Changing Yoke's architecture (React, Tailwind, component structure stays)
- Changing any tool's feature set or functionality
- Removing Yoke's 12 themes
- Making the tools visually identical — they share chrome but have different complexity
