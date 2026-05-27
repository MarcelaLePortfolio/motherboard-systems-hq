#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

set +e
bash scripts/_local/phase79_change_impact_preview.sh >"$TMP" 2>&1
CODE=$?
set -e

echo "PHASE 79 — CHANGE IMPACT PREVIEW SMOKE"
echo "--------------------------------------"

grep -q '^PHASE 79 — CHANGE IMPACT PREVIEW$' "$TMP"
grep -q '^IMPACT CHECK — CHANGED FILES$' "$TMP"
grep -q '^IMPACT CHECK — DIFF SUMMARY$' "$TMP"
grep -q '^IMPACT CHECK — PROTECTED AREAS$' "$TMP"
grep -q '^IMPACT CHECK — CHECKPOINT DELTA$' "$TMP"

if [[ "$CODE" -eq 0 ]]; then
  grep -q '^CHANGE IMPACT RESULT: REVIEW BEFORE COMMIT$' "$TMP"
fi

echo "PASS: change impact preview contract verified"
