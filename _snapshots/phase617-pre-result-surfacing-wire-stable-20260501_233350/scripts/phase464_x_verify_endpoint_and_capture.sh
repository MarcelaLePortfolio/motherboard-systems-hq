#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_runtime_results_summary.txt"

mkdir -p docs

echo "PHASE 464.X — VERIFIED RUNTIME CHECK" > "$OUT"
echo "====================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Check server reachability" >> "$OUT"
if curl -s --max-time 2 http://localhost:3000 > /dev/null; then
  echo "Server reachable on :3000" >> "$OUT"
  SERVER_OK=1
else
  echo "Server NOT reachable on :3000" >> "$OUT"
  SERVER_OK=0
fi
echo >> "$OUT"

echo "STEP 2 — Check system health endpoint" >> "$OUT"
RESPONSE=$(curl -s --max-time 2 http://localhost:3000/api/diagnostics/system-health || echo "REQUEST_FAILED")

echo "Raw response:" >> "$OUT"
echo "$RESPONSE" >> "$OUT"
echo >> "$OUT"

COUNT=$(echo "$RESPONSE" | rg -o 'SYSTEM_HEALTH' | wc -l | tr -d ' ')

echo "SYSTEM_HEALTH occurrences: $COUNT" >> "$OUT"
echo >> "$OUT"

STATUS="UNKNOWN"

if [ "$SERVER_OK" -eq 0 ]; then
  STATUS="SERVER_DOWN"
elif [ "$RESPONSE" = "REQUEST_FAILED" ]; then
  STATUS="ENDPOINT_FAILED"
elif [ "$COUNT" -eq 1 ]; then
  STATUS="FIX_CONFIRMED"
elif [ "$COUNT" -gt 1 ]; then
  STATUS="UPSTREAM_DUPLICATION"
elif [ "$COUNT" -eq 0 ]; then
  STATUS="SIGNAL_MISSING"
fi

echo "STATUS: $STATUS" >> "$OUT"

echo "Wrote $OUT"
echo "STATUS: $STATUS"

