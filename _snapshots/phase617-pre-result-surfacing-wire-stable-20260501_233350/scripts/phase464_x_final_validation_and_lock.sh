#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_final_validation_and_lock.txt"

mkdir -p docs

echo "PHASE 464.X — FINAL VALIDATION + STABILITY LOCK" > "$OUT"
echo "===============================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Verify endpoint stability (3 consecutive calls)" >> "$OUT"

PASS_COUNT=0

for i in 1 2 3; do
  RESPONSE=$(curl -s --max-time 3 http://localhost:3000/api/diagnostics/system-health || echo "REQUEST_FAILED")
  COUNT=$(echo "$RESPONSE" | rg -o 'SYSTEM_HEALTH' | wc -l | tr -d ' ')
  
  echo "Attempt $i → COUNT: $COUNT" >> "$OUT"
  
  if [ "$COUNT" -eq 1 ]; then
    PASS_COUNT=$((PASS_COUNT+1))
  fi
  
  sleep 1
done

echo >> "$OUT"
echo "STEP 2 — Evaluate stability" >> "$OUT"

if [ "$PASS_COUNT" -eq 3 ]; then
  STATUS="STABLE_CONFIRMED"
elif [ "$PASS_COUNT" -gt 0 ]; then
  STATUS="FLAKY_PARTIAL"
else
  STATUS="UNSTABLE"
fi

echo "PASS_COUNT: $PASS_COUNT / 3" >> "$OUT"
echo "STATUS: $STATUS" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Capture final container state" >> "$OUT"
docker compose ps >> "$OUT" 2>&1 || true
echo >> "$OUT"

echo "STEP 4 — Capture final logs snapshot" >> "$OUT"
docker compose logs --tail=50 >> "$OUT" 2>&1 || true
echo >> "$OUT"

echo "FINAL STATUS: $STATUS"
echo "Wrote $OUT"

