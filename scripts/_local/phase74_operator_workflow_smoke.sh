#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

set +e
bash scripts/_local/phase74_operator_workflow_helper.sh >"$TMP" 2>&1
CODE=$?
set -e

echo "PHASE 74 — OPERATOR WORKFLOW SMOKE"
echo "----------------------------------"

grep -q '^PHASE 74 — OPERATOR WORKFLOW HELPER$' "$TMP"
grep -q '^STEP 1 — SAFETY GATE$' "$TMP"
grep -q '^STEP 2 — GUIDANCE STATUS$' "$TMP"
grep -q '^STEP 3 — GUIDANCE SMOKE$' "$TMP"
grep -q '^STEP 4 — PROTECTION GATE$' "$TMP"
grep -q '^STEP 5 — DASHBOARD HEALTH$' "$TMP"

if [[ "$CODE" -eq 0 ]]; then
  grep -q '^WORKFLOW RESULT: SAFE DEVELOPMENT STATE VERIFIED$' "$TMP"
else
  grep -q '^WORKFLOW STOPPED — SAFETY GATE FAILED$' "$TMP"
fi

echo "PASS: workflow helper contract verified"
