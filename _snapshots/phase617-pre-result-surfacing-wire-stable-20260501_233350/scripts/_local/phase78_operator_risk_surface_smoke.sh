#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

set +e
bash scripts/_local/phase78_operator_risk_surface.sh >"$TMP" 2>&1
CODE=$?
set -e

echo "PHASE 78 — OPERATOR RISK SURFACE SMOKE"
echo "--------------------------------------"

grep -q '^PHASE 78 — OPERATOR RISK SURFACE$' "$TMP"
grep -q '^RISK CHECK — SAFETY GATE$' "$TMP"
grep -q '^RISK CHECK — WORKTREE DIRTINESS$' "$TMP"
grep -q '^RISK CHECK — UNPUSHED COMMITS$' "$TMP"
grep -q '^RISK CHECK — CONTAINER STATE$' "$TMP"

if [[ "$CODE" -eq 0 ]]; then
  grep -q '^RISK SURFACE RESULT: REVIEW COMPLETE$' "$TMP"
fi

echo "PASS: operator risk surface contract verified"
