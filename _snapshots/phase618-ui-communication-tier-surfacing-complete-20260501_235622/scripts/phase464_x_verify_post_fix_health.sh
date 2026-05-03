#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_post_fix_health_check.txt"

mkdir -p docs

echo "PHASE 464.X — POST-FIX HEALTH VERIFICATION" > "$OUT"
echo "==========================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Check container status" >> "$OUT"
docker compose ps >> "$OUT" 2>&1 || echo "docker unavailable" >> "$OUT"
echo >> "$OUT"

echo "STEP 2 — Wait for server stabilization" >> "$OUT"
sleep 3
echo "Waited 3 seconds" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Hit system health endpoint" >> "$OUT"
RESPONSE=$(curl -s --max-time 3 http://localhost:3000/api/diagnostics/system-health || echo "REQUEST_FAILED")
echo "$RESPONSE" >> "$OUT"
echo >> "$OUT"

COUNT=$(echo "$RESPONSE" | rg -o 'SYSTEM_HEALTH' | wc -l | tr -d ' ')

echo "SYSTEM_HEALTH occurrences: $COUNT" >> "$OUT"
echo >> "$OUT"

STATUS="UNKNOWN"

if [ "$RESPONSE" = "REQUEST_FAILED" ]; then
  STATUS="SERVER_NOT_RESPONDING"
elif [ "$COUNT" -eq 1 ]; then
  STATUS="HEALTHY_SINGLE_SIGNAL"
elif [ "$COUNT" -gt 1 ]; then
  STATUS="DUPLICATION_PRESENT"
elif [ "$COUNT" -eq 0 ]; then
  STATUS="SIGNAL_MISSING"
fi

echo "STATUS: $STATUS" >> "$OUT"
echo >> "$OUT"

echo "STEP 4 — Tail recent logs (sanity check)" >> "$OUT"
docker compose logs --tail=50 >> "$OUT" 2>&1 || echo "no logs" >> "$OUT"
echo >> "$OUT"

echo "Wrote $OUT"
echo "STATUS: $STATUS"

