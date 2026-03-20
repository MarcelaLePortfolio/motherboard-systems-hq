#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

set +e
bash scripts/_local/phase75_operator_preflight.sh >"$TMP" 2>&1
CODE=$?
set -e

echo "PHASE 75 — OPERATOR PREFLIGHT SMOKE"
echo "-----------------------------------"

grep -q '^PHASE 75 — OPERATOR PREFLIGHT$' "$TMP"
grep -q '^CHECK 1 — WORKFLOW HELPER$' "$TMP"
grep -q '^CHECK 2 — REPLAY CORPUS$' "$TMP"
grep -q '^CHECK 3 — DRIFT DETECTION$' "$TMP"
grep -q '^CHECK 4 — TELEMETRY REDUCERS$' "$TMP"
grep -q '^CHECK 5 — CONTAINER HEALTH$' "$TMP"

if [[ "$CODE" -eq 0 ]]; then
  grep -q '^PREFLIGHT RESULT: SYSTEM READY FOR SAFE ITERATION$' "$TMP"
fi

echo "PASS: operator preflight contract verified"
