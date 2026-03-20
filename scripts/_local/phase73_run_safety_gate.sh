#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "RUNNING OPERATOR SAFETY GATE"
echo "----------------------------"

if bash scripts/_local/phase73_operator_safety_gate.sh; then
  echo "RESULT: SAFE TO PROCEED"
else
  CODE=$?
  if [[ "$CODE" -eq 2 ]]; then
    echo "RESULT: BLOCKED — RESTORE REQUIRED"
  else
    echo "RESULT: CAUTION — INVESTIGATION ADVISED"
  fi
  exit "$CODE"
fi
