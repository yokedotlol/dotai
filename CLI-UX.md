# CLI-UX.md — CLI Distribution & UX Standards

## Distribution Matrix

Every tool with a CLI ships through these channels:

| Channel | Format | Tooling | Example |
|---------|--------|---------|---------|
| **Go binary** | CLI + library | GoReleaser + GitHub Releases | `brew install yokedotlol/tap/{tool}` |
| **Homebrew** | Tap formula | GoReleaser auto-generates | `yokedotlol/tap/{tool}` |
| **curl\|bash** | Install script | Hosted at `https://{tool}.lol/install.sh` | `curl -sL {tool}.lol/install.sh \| bash` |
| **npm** | Library + npx | Published to npmjs | `npx @yokedotlol/{tool}` |
| **pip** | Library + CLI | Published to PyPI | `pip install {tool}` / `python -m {tool}` |
| **bash script** | Standalone `.sh` | Hosted at `https://{tool}.lol/{tool}.sh` | `curl -sL {tool}.lol/{tool}.sh \| bash -s -- args` |

Not every tool needs every channel. Minimum: Go binary + Homebrew + curl|bash.

## Go CLI Conventions

### Module Structure
```
github.com/yokedotlol/{tool}
├── cmd/{tool}/main.go     ← CLI entrypoint
├── {tool}.go              ← Library package (Validate, Analyze, etc.)
├── pow.go                 ← PoW solver (if tool uses PoW)
└── ...
```

One module = CLI + library. Go devs `go get` the module; CLI users `brew install`.

### GoReleaser Config
- Binary name: `{tool}`
- Archives: tar.gz (Linux/macOS), zip (Windows)
- Homebrew tap: `yokedotlol/tap`
- Changelog: auto-generated from commits

### Release Flow
```bash
git tag v1.2.3
git push origin v1.2.3
# GoReleaser runs via GitHub Actions on tag push
```

## Output Formatting

### Default (TTY detected)
- Colored output using ANSI codes
- Grade/score prominently displayed
- Findings grouped by severity
- Copy-paste fix suggestions where applicable

### JSON (`--json` flag or `Accept: application/json`)
- Machine-readable structured output
- Same schema as the API response
- Pipe-friendly: `{tool} example.com --json | jq '.grade'`

### Quiet (`--quiet` flag)
- Exit code only: 0 = pass, 1 = fail
- For CI/CD scripts

### Exit Codes
```
0 — Success (pass, grade A/B)
1 — Failure (fail, grade D/F, or findings above threshold)
2 — Error (network error, invalid input, probe blocked)
```

## PoW in CLI

CLI handles PoW transparently:
1. Make request
2. If 429 with PoW challenge → solve locally → resubmit
3. User never sees the challenge

Show a brief spinner/message during PoW solving:
```
⚡ Solving proof-of-work challenge...
```

## Install Script Pattern

`https://{tool}.lol/install.sh` should:
1. Detect OS + architecture
2. Download the latest release from GitHub
3. Verify checksum
4. Install to `/usr/local/bin` (or `~/.local/bin` if no sudo)
5. Print version confirmation

Template from certs.lol's installer.

## npm Package Conventions

- Scoped: `@yokedotlol/{tool}`
- Exports: named exports, no default
- TypeScript: ship `.d.ts` types
- ESM + CJS dual publish
- `bin` field for `npx` support

## pip Package Conventions

- Name: `{tool}` on PyPI (if available, otherwise `{tool}-lol`)
- `__main__.py` for `python -m {tool}` support
- Type hints throughout
- `setup.cfg` or `pyproject.toml` (modern)
