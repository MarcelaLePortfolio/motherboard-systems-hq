#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

set +e
bash scripts/_local/phase76_operator_start_command.sh >"$TMP" 2>&1
CODE=$?
set -e

echo "PHASE 76 — OPERATOR START COMMAND SMOKE"
echo "---------------------------------------"

grep -q '^PHASE 76 — OPERATOR START COMMAND$' "$TMP"
grep -q '^generated_at=' "$TMP"
grep -q '^repo=' "$TMP"
grep -q '^branch=' "$TMP"
grep -q '^commit=' "$TMP"
grep -q '^STEP 1 — PREFLIGHT$' "$TMP"
grep -q '^STEP 2 — GUIDANCE STATUS$' "$TMP"
grep -q '^STEP 3 — NEXT ACTION$' "$TMP"
grep -q '^STEP 4 — LAST CHECKPOINTS$' "$TMP"
grep -q '^STEP 5 — WORKTREE$' "$TMP"

if [[ "$CODE" -eq 0 ]]; then
  grep -q '^START COMMAND RESULT: OPERATOR READY$' "$TMP"
fi

echo "PASS: operator start command contract verified"
