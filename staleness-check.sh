#!/usr/bin/env bash
# staleness-check.sh — Verify .ai/ docs match deployed state
# Run from the root of any .lol product repo
set -euo pipefail

TOOL_NAME=$(basename "$(pwd)" | sed 's/-lol$//' | sed 's/-public$//')
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

stale=0

check() {
  local label="$1" result="$2"
  if [ "$result" = "ok" ]; then
    echo -e "  ${GREEN}✓${NC} $label"
  else
    echo -e "  ${RED}✗${NC} $label — $result"
    stale=$((stale + 1))
  fi
}

warn() {
  local label="$1" msg="$2"
  echo -e "  ${YELLOW}⚠${NC} $label — $msg"
}

echo "=== .ai staleness check for $TOOL_NAME ==="
echo ""

# 1. Check base submodule exists
echo "Base layer:"
if [ -d ".ai/base" ]; then
  check "Submodule present" "ok"
  # Check if submodule is up to date
  cd .ai/base
  git fetch origin main --quiet 2>/dev/null
  LOCAL=$(git rev-parse HEAD 2>/dev/null)
  REMOTE=$(git rev-parse origin/main 2>/dev/null || echo "unknown")
  cd ../..
  if [ "$LOCAL" = "$REMOTE" ]; then
    check "Submodule up to date" "ok"
  else
    check "Submodule up to date" "behind origin/main"
  fi
else
  check "Submodule present" ".ai/base/ not found"
fi

# 2. Check required product files
echo ""
echo "Product layer:"
for f in STATE.md DECISIONS.md INVARIANTS.md; do
  if [ -f ".ai/$f" ]; then
    check "$f exists" "ok"
  else
    warn "$f" "not found (optional but recommended)"
  fi
done

# 3. Check .gitignore excludes .ai/ work products
echo ""
echo "Git hygiene:"
if grep -q "\.ai/" .gitignore 2>/dev/null || grep -q "PANEL-REVIEW" .gitignore 2>/dev/null; then
  check ".gitignore covers work products" "ok"
else
  check ".gitignore covers work products" "add .ai/ and PANEL-REVIEW* to .gitignore"
fi

# 4. Check no secrets in tracked .ai/ files
echo ""
echo "Secrets scan:"
if grep -rli "api.key\|api_token\|secret\|password\|bearer" .ai/ 2>/dev/null | grep -v "staleness-check.sh" | head -1 > /dev/null 2>&1; then
  check "No secrets in .ai/" "potential secret found — review manually"
else
  check "No secrets in .ai/" "ok"
fi

echo ""
if [ "$stale" -gt 0 ]; then
  echo -e "${RED}$stale issue(s) found${NC}"
  exit 1
else
  echo -e "${GREEN}All checks passed${NC}"
  exit 0
fi
