#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_post_rebuild_deep_verify.txt"

mkdir -p docs

echo "PHASE 464.X — POST-REBUILD DEEP VERIFY" > "$OUT"
echo "======================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Container status" >> "$OUT"
docker compose ps >> "$OUT" 2>&1
echo >> "$OUT"

echo "STEP 2 — Check dashboard logs for startup errors" >> "$OUT"
docker compose logs --tail=120 >> "$OUT" 2>&1
echo >> "$OUT"

echo "STEP 3 — Direct port probe (TCP)" >> "$OUT"
nc -zv localhost 3000 >> "$OUT" 2>&1 || echo "port 3000 closed" >> "$OUT"
echo >> "$OUT"

echo "STEP 4 — HTTP root probe" >> "$OUT"
curl -i --max-time 3 http://localhost:3000 >> "$OUT" 2>&1 || echo "root failed" >> "$OUT"
echo >> "$OUT"

echo "STEP 5 — System health endpoint probe" >> "$OUT"
RESPONSE=$(curl -s --max-time 3 http://localhost:3000/api/diagnostics/system-health || echo "REQUEST_FAILED")
echo "$RESPONSE" >> "$OUT"
echo >> "$OUT"

COUNT=$(echo "$RESPONSE" | rg -o 'SYSTEM_HEALTH' | wc -l | tr -d ' ')

echo "SYSTEM_HEALTH occurrences: $COUNT" >> "$OUT"
echo >> "$OUT"

STATUS="UNKNOWN"

if echo "$RESPONSE" | rg -q "Cannot find module"; then
  STATUS="MISSING_DEPENDENCY"
elif echo "$RESPONSE" | rg -q "Error"; then
  STATUS="RUNTIME_ERROR"
elif [ "$RESPONSE" = "REQUEST_FAILED" ]; then
  STATUS="SERVER_NOT_RESPONDING"
elif [ "$COUNT" -eq 1 ]; then
  STATUS="FULLY_HEALTHY"
elif [ "$COUNT" -gt 1 ]; then
  STATUS="DUPLICATION_PRESENT"
elif [ "$COUNT" -eq 0 ]; then
  STATUS="NO_SIGNAL"
fi

echo "STATUS: $STATUS" >> "$OUT"

echo >> "$OUT"
echo "DIAGNOSIS COMPLETE" >> "$OUT"

echo "Wrote $OUT"
echo "STATUS: $STATUS"

