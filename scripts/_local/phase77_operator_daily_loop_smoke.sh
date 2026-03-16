#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

set +e
bash scripts/_local/phase77_operator_daily_loop.sh >"$TMP" 2>&1
CODE=$?
set -e

echo "PHASE 77 — OPERATOR DAILY LOOP SMOKE"
echo "------------------------------------"

grep -q '^PHASE 77 — OPERATOR DAILY LOOP$' "$TMP"
grep -q '^LOOP STEP 1 — START COMMAND$' "$TMP"
grep -q '^LOOP STEP 2 — RISK SUMMARY$' "$TMP"
grep -q '^LOOP STEP 3 — CURRENT TASK SIGNALS$' "$TMP"
grep -q '^LOOP STEP 4 — RECENT EVENTS SNAPSHOT$' "$TMP"
grep -q '^LOOP STEP 5 — SAFE NEXT MOVE$' "$TMP"

if [[ "$CODE" -eq 0 ]]; then
  grep -q '^DAILY LOOP RESULT: OPERATOR IN CONTROL$' "$TMP"
fi

echo "PASS: operator daily loop contract verified"
