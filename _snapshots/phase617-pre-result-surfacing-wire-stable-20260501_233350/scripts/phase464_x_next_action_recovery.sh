#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_next_action_recovery.txt"

mkdir -p docs

echo "PHASE 464.X — NEXT ACTION: ENDPOINT FAILURE RECOVERY" > "$OUT"
echo "====================================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Docker status" >> "$OUT"
docker compose ps >> "$OUT" 2>&1 || echo "docker compose not available" >> "$OUT"
echo >> "$OUT"

echo "STEP 2 — Restart dashboard container" >> "$OUT"
docker compose up -d >> "$OUT" 2>&1 || echo "failed to start containers" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Wait for service" >> "$OUT"
sleep 3
echo "Waited 3 seconds for service boot" >> "$OUT"
echo >> "$OUT"

echo "STEP 4 — Re-test endpoint" >> "$OUT"
RESPONSE=$(curl -s --max-time 3 http://localhost:3000/api/diagnostics/system-health || echo "REQUEST_FAILED")
echo "$RESPONSE" >> "$OUT"
echo >> "$OUT"

COUNT=$(echo "$RESPONSE" | rg -o 'SYSTEM_HEALTH' | wc -l | tr -d ' ')

STATUS="UNKNOWN"

if [ "$RESPONSE" = "REQUEST_FAILED" ]; then
  STATUS="STILL_DOWN"
elif [ "$COUNT" -eq 1 ]; then
  STATUS="RECOVERED_FIX_CONFIRMED"
elif [ "$COUNT" -gt 1 ]; then
  STATUS="RECOVERED_BUT_DUPLICATED"
elif [ "$COUNT" -eq 0 ]; then
  STATUS="RECOVERED_SIGNAL_MISSING"
fi

echo "STATUS: $STATUS" >> "$OUT"

echo "Wrote $OUT"
echo "STATUS: $STATUS"

