#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

set +e
bash scripts/_local/phase80_safe_iteration_engine.sh >"$TMP" 2>&1
CODE=$?
set -e

echo "PHASE 80 — SAFE ITERATION ENGINE SMOKE"
echo "--------------------------------------"

grep -q '^PHASE 80 — SAFE ITERATION ENGINE$' "$TMP"
grep -q '^ENGINE STEP 1 — START COMMAND$' "$TMP"
grep -q '^ENGINE STEP 2 — DAILY LOOP$' "$TMP"
grep -q '^ENGINE STEP 3 — RISK SURFACE$' "$TMP"
grep -q '^ENGINE STEP 4 — CHANGE IMPACT PREVIEW$' "$TMP"
grep -q '^ENGINE STEP 5 — PREFLIGHT SMOKE$' "$TMP"
grep -q '^ENGINE STEP 6 — START COMMAND SMOKE$' "$TMP"
grep -q '^ENGINE STEP 7 — DAILY LOOP SMOKE$' "$TMP"
grep -q '^ENGINE STEP 8 — RISK SURFACE SMOKE$' "$TMP"
grep -q '^ENGINE STEP 9 — CHANGE IMPACT SMOKE$' "$TMP"

if [[ "$CODE" -eq 0 ]]; then
  grep -q '^SAFE ITERATION ENGINE RESULT: READY FOR CONTROLLED DEVELOPMENT$' "$TMP"
fi

echo "PASS: safe iteration engine contract verified"
