#!/usr/bin/env bash
# .lol Family Audit — checks shared invariants across all tools
# Usage: ./audit.sh [all|yoke|certs|ns|xhttp|vrfy] [--live|--repo|--both]
# Requires: curl, dig, jq, grep
set -uo pipefail

# ─── Colors ──────────────────────────────────────────────────────────
R='\033[0;31m' G='\033[0;32m' Y='\033[0;33m' B='\033[0;34m'
DIM='\033[0;90m' BOLD='\033[1m' RST='\033[0m'

# ─── Tool Registry ──────────────────────────────────────────────────
# Format: name|domain|type|api_path|test_domain|repo_dir
TOOLS=(
  "yoke|yoke.lol|hub|/api/health|stripe.com|"
  "certs|certs.lol|feeder|/stripe.com|stripe.com|"
  "ns|ns.lol|feeder|/stripe.com|stripe.com|"
  "xhttp|xhttp.lol|crossref|/stripe.com|stripe.com|"
  "vrfy|vrfy.lol|standalone||stripe.com|"
)

# Auto-detect repo dirs relative to this script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(dirname "$SCRIPT_DIR")"

declare -A REPO_DIRS=(
  [yoke]="$WORKSPACE/yoke-public"
  [certs]="$WORKSPACE/certs-lol"
  [ns]="$WORKSPACE/ns-lol"
  [xhttp]="$WORKSPACE/xhttp-lol"
  [vrfy]="$WORKSPACE/vrfy-lol"
)

# ─── Counters ────────────────────────────────────────────────────────
PASS=0 FAIL=0 SKIP=0 WARN=0

pass()  { PASS=$((PASS+1)); printf "  ${G}✓${RST} ${DIM}#%-3s${RST} %s\n" "$1" "$2"; }
fail()  { FAIL=$((FAIL+1)); printf "  ${R}✗${RST} ${DIM}#%-3s${RST} %s\n" "$1" "$2"; }
warn()  { WARN=$((WARN+1)); printf "  ${Y}~${RST} ${DIM}#%-3s${RST} %s\n" "$1" "$2"; }
skip()  { SKIP=$((SKIP+1)); printf "  ${DIM}–${RST} ${DIM}#%-3s${RST} %s\n" "$1" "$2"; }
header(){ printf "\n${BOLD}${B}▸ %s${RST}\n" "$1"; }

# ─── Parse Args ──────────────────────────────────────────────────────
TARGET="${1:-all}"
MODE="${2:---both}"

# ─── Helpers ─────────────────────────────────────────────────────────
get_field() { echo "$1" | cut -d'|' -f"$2"; }

curl_headers() {
  curl -sI -m 10 "https://$1" 2>/dev/null || true
}

curl_json() {
  curl -s -m 15 -H "Accept: application/json" "https://$1" 2>/dev/null || true
}

dig_txt() {
  dig +short TXT "$1" 2>/dev/null | tr -d '"'
}

has_header() {
  local headers="$1" name="$2"
  echo "$headers" | grep -qi "^${name}:" && return 0 || return 1
}

get_header() {
  local headers="$1" name="$2"
  echo "$headers" | grep -i "^${name}:" | head -1 | sed 's/^[^:]*: *//' | tr -d '\r'
}

# ─── Live Checks ─────────────────────────────────────────────────────

run_live_checks() {
  local name="$1" domain="$2" type="$3" api_path="$4" test_domain="$5"

  header "$name ($domain) — live checks"

  # Fetch headers once
  local hdrs
  hdrs=$(curl_headers "$domain")

  # ── 3: No cookies ──
  if has_header "$hdrs" "set-cookie"; then
    fail 3 "Set-Cookie header found"
  else
    pass 3 "No cookies"
  fi

  # ── 5: HTTPS + HSTS ──
  if has_header "$hdrs" "strict-transport-security"; then
    local hsts_val
    hsts_val=$(get_header "$hdrs" "strict-transport-security")
    if echo "$hsts_val" | grep -qi "preload"; then
      pass 5 "HSTS with preload"
    else
      warn 5 "HSTS present but no preload directive"
    fi
  else
    fail 5 "No HSTS header"
  fi

  # ── Security headers (part of infra) ──
  local sec_headers=("x-content-type-options" "x-frame-options" "referrer-policy" "content-security-policy")
  local sec_pass=true
  local sec_missing=""
  for sh in "${sec_headers[@]}"; do
    if ! has_header "$hdrs" "$sh"; then
      sec_pass=false
      sec_missing="${sec_missing} ${sh}"
    fi
  done
  if $sec_pass; then
    pass "—" "Security headers present (XCTO, XFO, RP, CSP)"
  else
    fail "—" "Missing security headers:${sec_missing}"
  fi

  # ── 6: DNSSEC ──
  local dnssec
  dnssec=$(dig +short DS "$domain" 2>/dev/null)
  if [ -n "$dnssec" ]; then
    pass 6 "DNSSEC enabled"
  else
    fail 6 "No DS records (DNSSEC not enabled)"
  fi

  # ── 7: SPF hard fail ──
  local spf
  spf=$(dig_txt "$domain" | grep "v=spf1" || true)
  if echo "$spf" | grep -q "\-all"; then
    pass 7 "SPF hard fail (-all)"
  elif echo "$spf" | grep -q "~all"; then
    fail 7 "SPF soft fail (~all) — should be -all"
  elif [ -z "$spf" ]; then
    fail 7 "No SPF record"
  else
    warn 7 "SPF present but no -all: $spf"
  fi

  # ── 8: DMARC reject ──
  local dmarc
  dmarc=$(dig_txt "_dmarc.$domain" || true)
  if echo "$dmarc" | grep -q "p=reject"; then
    if echo "$dmarc" | grep -q "sp=reject"; then
      pass 8 "DMARC p=reject; sp=reject"
    else
      warn 8 "DMARC p=reject but sp≠reject"
    fi
  else
    fail 8 "DMARC not set to reject"
  fi

  # ── 9: CAA records ──
  local caa
  caa=$(dig +short CAA "$domain" 2>/dev/null)
  if [ -n "$caa" ]; then
    pass 9 "CAA records present"
  else
    fail 9 "No CAA records"
  fi

  # ── 10: security.txt ──
  local sectxt
  sectxt=$(curl -s -m 5 "https://$domain/.well-known/security.txt" 2>/dev/null || true)
  if echo "$sectxt" | grep -qi "github"; then
    pass 10 "security.txt Contact = GitHub"
  elif [ -n "$sectxt" ]; then
    warn 10 "security.txt exists but Contact may not be GitHub Issues"
  else
    fail 10 "No security.txt"
  fi

  # ── 28: Privacy page ──
  local priv_status
  priv_status=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "https://$domain/privacy" 2>/dev/null)
  if [ "$priv_status" = "200" ]; then
    pass 28 "/privacy returns 200"
  else
    fail 28 "/privacy returns $priv_status"
  fi

  # ── 29: Terms page ──
  local terms_status
  terms_status=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "https://$domain/terms" 2>/dev/null)
  if [ "$terms_status" = "200" ]; then
    pass 29 "/terms returns 200"
  else
    fail 29 "/terms returns $terms_status"
  fi

  # ── API checks (17-22) — skip for standalone ──
  if [ -n "$api_path" ]; then
    # 17: GET /{domain} primary
    local api_status
    api_status=$(curl -s -o /dev/null -w "%{http_code}" -m 15 -H "Accept: application/json" "https://${domain}${api_path}" 2>/dev/null)
    if [ "$api_status" = "200" ]; then
      pass 17 "GET ${api_path} returns 200"
    else
      fail 17 "GET ${api_path} returns $api_status"
    fi

    # 18: JSON for API clients
    local api_ct
    api_ct=$(curl -s -m 15 -H "Accept: application/json" -o /dev/null -w "%{content_type}" "https://${domain}${api_path}" 2>/dev/null)
    if echo "$api_ct" | grep -qi "json"; then
      pass 18 "JSON content-type for API clients"
    else
      fail 18 "Content-Type: $api_ct (expected JSON)"
    fi

    # 19: _meta block
    local meta
    meta=$(curl_json "${domain}${api_path}" | jq '._meta' 2>/dev/null)
    if [ "$meta" != "null" ] && [ -n "$meta" ]; then
      pass 19 "_meta block present"

      # 20/21: full_report based on type
      local has_full
      has_full=$(echo "$meta" | jq -r '.full_report // empty' 2>/dev/null)
      case "$type" in
        feeder|crossref)
          if [ -n "$has_full" ]; then
            pass 20 "_meta.full_report present (${type})"
          else
            # crossref tools use _meta.links.full_report
            local links_full
            links_full=$(echo "$meta" | jq -r '.links.full_report // empty' 2>/dev/null)
            if [ -n "$links_full" ]; then
              pass 20 "_meta.links.full_report present (${type})"
            else
              fail 20 "No full_report link (${type} tool should have one)"
            fi
          fi
          ;;
        standalone)
          if [ -z "$has_full" ]; then
            pass 21 "No full_report (standalone — correct)"
          else
            fail 21 "Standalone tool should NOT have full_report"
          fi
          ;;
        hub)
          skip 20 "Hub tool — full_report N/A"
          ;;
      esac
    else
      fail 19 "No _meta block in API response"
    fi
  else
    skip 17 "No API endpoint defined for $name"
    skip 18 "No API endpoint defined for $name"
    skip 19 "No API endpoint defined for $name"
  fi

  # ── MTA-STS ──
  local mtasts_status
  mtasts_status=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "https://mta-sts.${domain}/.well-known/mta-sts.txt" 2>/dev/null)
  if [ "$mtasts_status" = "200" ]; then
    pass "—" "MTA-STS endpoint responds"
  else
    warn "—" "MTA-STS returns $mtasts_status"
  fi

  # ── Infrastructure pages ──
  for page in robots.txt sitemap.xml; do
    local pg_status
    pg_status=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "https://$domain/$page" 2>/dev/null)
    if [ "$pg_status" = "200" ]; then
      pass "—" "/$page returns 200"
    else
      warn "—" "/$page returns $pg_status"
    fi
  done
}

# ─── Repo Checks ─────────────────────────────────────────────────────

run_repo_checks() {
  local name="$1" domain="$2" type="$3" repo_dir="${REPO_DIRS[$1]:-}"

  if [ -z "$repo_dir" ] || [ ! -d "$repo_dir" ]; then
    header "$name — repo checks (skipped: no local checkout)"
    return
  fi

  header "$name ($repo_dir) — repo checks"

  # ── 11: Inter + JetBrains Mono ──
  local font_files
  font_files=$(grep -rl "font-family\|fontFamily" "$repo_dir" --include="*.css" --include="*.tsx" --include="*.ts" --include="*.html" 2>/dev/null | grep -v node_modules | grep -v dist || true)
  if [ -n "$font_files" ]; then
    local bad_fonts
    bad_fonts=$(grep -h "font-family\|fontFamily" $font_files 2>/dev/null | grep -vi "inter\|jetbrains\|monospace\|sans-serif\|inherit\|var(--\|system-ui\|mono)\|Verdana\|DejaVu\|Geneva" || true)
    if [ -z "$bad_fonts" ]; then
      pass 11 "Fonts: Inter + JetBrains Mono only"
    else
      warn 11 "Non-standard fonts found — review manually"
    fi
  else
    skip 11 "No font declarations found"
  fi

  # ── 12: Dark-mode-first ──
  local theme_default
  theme_default=$(grep -r "localStorage\|theme.*default\|data-theme" "$repo_dir" --include="*.ts" --include="*.tsx" --include="*.html" --include="*.css" 2>/dev/null | grep -v node_modules | grep -v dist | grep -i "dark" | head -1 || true)
  if [ -n "$theme_default" ]; then
    pass 12 "Dark-mode default detected"
  else
    warn 12 "Could not confirm dark-mode default — check manually"
  fi

  # ── 23: GitHub Actions ──
  if [ -d "$repo_dir/.github/workflows" ]; then
    local wf_count
    wf_count=$(ls "$repo_dir/.github/workflows/"*.yml "$repo_dir/.github/workflows/"*.yaml 2>/dev/null | wc -l)
    pass 23 "GitHub Actions: $wf_count workflow(s)"
  else
    fail 23 "No .github/workflows directory"
  fi

  # ── 26: .ai/ in .gitignore ──
  if [ -f "$repo_dir/.gitignore" ]; then
    if grep -q "\.ai/" "$repo_dir/.gitignore" 2>/dev/null || grep -q "\.ai/\*" "$repo_dir/.gitignore" 2>/dev/null; then
      pass 26 ".ai/ work products in .gitignore"
    else
      # Check if .ai exists but isn't ignored
      if [ -d "$repo_dir/.ai" ]; then
        warn 26 ".ai/ directory exists but not in .gitignore"
      else
        skip 26 "No .ai/ directory"
      fi
    fi
  else
    warn 26 "No .gitignore file"
  fi

  # ── .ai/ structure ──
  if [ -d "$repo_dir/.ai" ]; then
    local ai_files=("CONSTITUTION.md" "INVARIANTS.md" "STATE.md" "DECISIONS.md" "GOTCHAS.md")
    local ai_missing=""
    for f in "${ai_files[@]}"; do
      if [ ! -f "$repo_dir/.ai/$f" ]; then
        ai_missing="${ai_missing} ${f}"
      fi
    done
    if [ -z "$ai_missing" ]; then
      pass "—" ".ai/ structure complete"
    else
      warn "—" "Missing .ai/ files:${ai_missing}"
    fi
  else
    warn "—" "No .ai/ directory"
  fi

  # ── git hooks ──
  local hooks_path
  hooks_path=$(cd "$repo_dir" && git config core.hooksPath 2>/dev/null || true)
  if [ -n "$hooks_path" ]; then
    pass "—" "git hooks: core.hooksPath = $hooks_path"
  else
    warn "—" "core.hooksPath not set"
  fi

  # ── 15: Family links (check source for sibling domains) ──
  local siblings=("yoke.lol" "certs.lol" "ns.lol" "xhttp.lol" "vrfy.lol")
  local missing_links=""
  for sib in "${siblings[@]}"; do
    [ "$sib" = "$domain" ] && continue
    local found
    found=$(grep -rl "$sib" "$repo_dir" --include="*.ts" --include="*.tsx" --include="*.html" 2>/dev/null | grep -v node_modules | grep -v dist | head -1 || true)
    if [ -z "$found" ]; then
      missing_links="${missing_links} ${sib}"
    fi
  done
  if [ -z "$missing_links" ]; then
    pass 15 "Family links: all siblings referenced"
  else
    warn 15 "Missing family links:${missing_links}"
  fi
}

# ─── Run ─────────────────────────────────────────────────────────────

printf "\n${BOLD}.lol Family Audit${RST}\n"
printf "${DIM}$(date -u '+%Y-%m-%d %H:%M:%S UTC')${RST}\n"

for tool_spec in "${TOOLS[@]}"; do
  name=$(get_field "$tool_spec" 1)
  domain=$(get_field "$tool_spec" 2)
  type=$(get_field "$tool_spec" 3)
  api_path=$(get_field "$tool_spec" 4)
  test_domain=$(get_field "$tool_spec" 5)

  # Filter
  if [ "$TARGET" != "all" ] && [ "$TARGET" != "$name" ]; then
    continue
  fi

  if [ "$MODE" != "--repo" ]; then
    run_live_checks "$name" "$domain" "$type" "$api_path" "$test_domain"
  fi

  if [ "$MODE" != "--live" ]; then
    run_repo_checks "$name" "$domain" "$type"
  fi
done

# ─── Summary ─────────────────────────────────────────────────────────
printf "\n${BOLD}─── Summary ───${RST}\n"
printf "  ${G}✓ %d passed${RST}  ${R}✗ %d failed${RST}  ${Y}~ %d warnings${RST}  ${DIM}– %d skipped${RST}\n\n" "$PASS" "$FAIL" "$WARN" "$SKIP"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
