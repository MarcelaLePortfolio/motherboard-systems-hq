#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

echo "=== phase40.1 check: shadow-mode wiring present (guarded, audit-only) ==="
test -f server/policy/policy_flags.mjs
test -f server/policy/policy_eval.mjs
test -f server/policy/policy_audit.mjs
FOUND_FILE="$(
  rg -n -l \
    --glob '!server/policy/**' \
    --glob '!scripts/_ops/**' \
    'if\s*\(\s*policyShadowEnabled\(' \
    server scripts runSkill.ts scripts/utils/runSkill.ts 2>/dev/null \
  | while read -r f; do
      rg -n 'policyEvalShadow' "$f" >/dev/null 2>&1 || continue
      rg -n 'policyAuditWrite' "$f" >/dev/null 2>&1 || continue
      echo "$f"
      break
    done
)"

: "${FOUND_FILE:?ERROR: no execution-path file contains guarded shadow wiring (exclude server/policy + scripts/_ops)}"
echo "FOUND_EXECUTION_WIRING_FILE=$FOUND_FILE"

echo "OK: wiring present + guarded in execution path"
