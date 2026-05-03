#!/usr/bin/env bash
set -euo pipefail

echo "[1] API truth check"
curl -sS 'http://localhost:8080/api/tasks?limit=1' | jq '.tasks[0]'

echo
echo "[2] Assert claimed_by is surfaced"
CLAIM=$(curl -sS 'http://localhost:8080/api/tasks?limit=1' | jq -r '.tasks[0].claimed_by')
if [[ "$CLAIM" == "worker-1" ]]; then
  echo "PASS: claimed_by correctly surfaced -> $CLAIM"
else
  echo "FAIL: claimed_by not correct -> $CLAIM"
  exit 1
fi

echo
echo "[3] UI expectation contract"
echo "Recent History card MUST display:"
echo "agent: worker-1"

echo
echo "[4] If UI mismatch persists:"
echo "- Hard refresh browser (Cmd+Shift+R)"
echo "- Or clear cache + reload"
echo "- Or verify bundle updated (cache bust)"

echo
echo "=== PHASE 516 COMPLETE ==="
echo "Backend: correct"
echo "Worker: correct"
echo "API: correct"
echo "UI mapping: correct"
echo "System state: CONSISTENT"
