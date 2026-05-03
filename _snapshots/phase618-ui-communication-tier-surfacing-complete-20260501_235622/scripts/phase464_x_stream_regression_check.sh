#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_stream_regression_check.txt"

mkdir -p docs

echo "PHASE 464.X — STREAM REGRESSION CHECK" > "$OUT"
echo "=====================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Capture 5 consecutive responses" >> "$OUT"

DUPLICATION_DETECTED=0
TOTAL_COUNT=0

for i in 1 2 3 4 5; do
  RESPONSE=$(curl -s --max-time 3 http://localhost:3000/api/diagnostics/system-health || echo "REQUEST_FAILED")
  COUNT=$(echo "$RESPONSE" | rg -o 'SYSTEM_HEALTH' | wc -l | tr -d ' ')
  
  echo "Attempt $i → COUNT: $COUNT" >> "$OUT"
  
  TOTAL_COUNT=$((TOTAL_COUNT + COUNT))
  
  if [ "$COUNT" -gt 1 ]; then
    DUPLICATION_DETECTED=1
  fi

  sleep 1
done

echo >> "$OUT"

echo "STEP 2 — Evaluate stream behavior" >> "$OUT"

if [ "$DUPLICATION_DETECTED" -eq 0 ]; then
  STATUS="STREAM_RESOLVED_SINGLE_EMISSION"
else
  STATUS="STREAM_STILL_DUPLICATING"
fi

echo "TOTAL SYSTEM_HEALTH COUNT (across 5 calls): $TOTAL_COUNT" >> "$OUT"
echo "STATUS: $STATUS" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Check if polling loop still active (logs)" >> "$OUT"
docker compose logs --tail=100 | rg -i "system_health|poll|loop|interval" >> "$OUT" || echo "no loop indicators found" >> "$OUT"
echo >> "$OUT"

echo "Wrote $OUT"
echo "STATUS: $STATUS"

