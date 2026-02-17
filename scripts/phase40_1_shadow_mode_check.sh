#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

echo "=== phase40.1 check: shadow-mode wiring present (guarded, audit-only) ==="

# Must exist somewhere in execution path(s)
REQ_PATTERNS=(
  "policyShadowEnabled"
  "policyEvalShadow"
  "policyAuditWrite"
)

FOUND_FILE="$(rg -n -l "${REQ_PATTERNS[1]}|${REQ_PATTERNS[2]}|${REQ_PATTERNS[0]}" server scripts runSkill.ts scripts/utils/runSkill.ts 2>/dev/null | head -n 1 || true)"
: "${FOUND_FILE:?ERROR: no file contains policy shadow wiring symbols}"

echo "FOUND_FILE=$FOUND_FILE"

for p in "${REQ_PATTERNS[@]}"; do
  rg -n --no-heading "$p" "$FOUND_FILE" >/dev/null
done

# Ensure the guard exists
rg -n --no-heading "if\s*\(\s*policyShadowEnabled\(" "$FOUND_FILE" >/dev/null

echo "OK: wiring present + guarded"
