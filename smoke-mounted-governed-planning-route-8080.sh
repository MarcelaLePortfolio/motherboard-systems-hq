
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="MOUNTED_GOVERNED_PLANNING_ROUTE_8080_SMOKE.txt"

PORT="${PORT:-8080}"

URL="http://localhost:${PORT}/api/governed-planning/dry-run"

rm -f "$OUTPUT"

echo "===== MOUNTED GOVERNED PLANNING ROUTE 8080 SMOKE =====" | tee "$OUTPUT"

date | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== ROUTE =====" | tee -a "$OUTPUT"

echo "$URL" | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== HTTP RESPONSE =====" | tee -a "$OUTPUT"

curl -sS -X POST "$URL" \

  -H "Content-Type: application/json" \

  --data @server/execution/smoke-test-governed-route-payload.json \

  | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== LOCAL IN-PROCESS CONTROL =====" | tee -a "$OUTPUT"

node server/execution/smoke-test-governed-route-inprocess.mjs | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== WORKTREE =====" | tee -a "$OUTPUT"

git status --short | tee -a "$OUTPUT"

git add smoke-mounted-governed-planning-route-8080.sh MOUNTED_GOVERNED_PLANNING_ROUTE_8080_SMOKE.txt

git commit -m "Smoke test governed planning route on Docker mapped port"

git push

