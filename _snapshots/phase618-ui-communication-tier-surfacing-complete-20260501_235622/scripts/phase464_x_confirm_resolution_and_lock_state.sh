#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_confirm_resolution_and_lock_state.txt"

mkdir -p docs

echo "PHASE 464.X — FINAL RESOLUTION CONFIRMATION" > "$OUT"
echo "===========================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Validate no repeated SYSTEM_HEALTH emissions" >> "$OUT"

PASS=1

for i in 1 2 3 4 5; do
  RESPONSE=$(curl -s --max-time 3 http://localhost:3000/api/diagnostics/system-health || echo "REQUEST_FAILED")
  COUNT=$(echo "$RESPONSE" | rg -o 'SYSTEM_HEALTH' | wc -l | tr -d ' ')

  echo "Attempt $i → COUNT: $COUNT" >> "$OUT"

  if [ "$COUNT" -ne 1 ]; then
    PASS=0
  fi

  sleep 1
done

echo >> "$OUT"

echo "STEP 2 — Determine final system state" >> "$OUT"

if [ "$PASS" -eq 1 ]; then
  STATUS="RESOLVED_STABLE_SINGLE_SIGNAL"
else
  STATUS="UNSTABLE_OR_PARTIAL_FIX"
fi

echo "STATUS: $STATUS" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Confirm server is consistently responding" >> "$OUT"
curl -s --max-time 3 http://localhost:3000 >> "$OUT" 2>&1 || echo "root endpoint failed" >> "$OUT"
echo >> "$OUT"

echo "STEP 4 — Capture minimal log snapshot" >> "$OUT"
docker compose logs --tail=30 >> "$OUT" 2>&1 || true
echo >> "$OUT"

echo "SYSTEM LOCK STATE:"
if [ "$STATUS" = "RESOLVED_STABLE_SINGLE_SIGNAL" ]; then
  echo "SAFE TO PROCEED — duplication issue resolved and system stable" >> "$OUT"
else
  echo "DO NOT ADVANCE — instability still present" >> "$OUT"
fi

echo >> "$OUT"
echo "Wrote $OUT"
echo "STATUS: $STATUS"

