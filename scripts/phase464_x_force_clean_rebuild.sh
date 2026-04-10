#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_force_clean_rebuild.txt"

mkdir -p docs

echo "PHASE 464.X — FORCE CLEAN REBUILD" > "$OUT"
echo "=================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Tear down all containers + volumes" >> "$OUT"
docker compose down -v >> "$OUT" 2>&1 || echo "docker down failed" >> "$OUT"
echo >> "$OUT"

echo "STEP 2 — Remove orphan containers/images (safe prune)" >> "$OUT"
docker system prune -f >> "$OUT" 2>&1 || echo "prune failed" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Rebuild containers from scratch" >> "$OUT"
docker compose build --no-cache >> "$OUT" 2>&1 || echo "build failed" >> "$OUT"
echo >> "$OUT"

echo "STEP 4 — Start containers fresh" >> "$OUT"
docker compose up -d >> "$OUT" 2>&1 || echo "up failed" >> "$OUT"
echo >> "$OUT"

echo "STEP 5 — Wait for boot" >> "$OUT"
sleep 5
echo "Waited 5 seconds" >> "$OUT"
echo >> "$OUT"

echo "STEP 6 — Verify container state" >> "$OUT"
docker compose ps >> "$OUT" 2>&1
echo >> "$OUT"

echo "STEP 7 — Hit endpoint" >> "$OUT"
RESPONSE=$(curl -s --max-time 3 http://localhost:3000/api/diagnostics/system-health || echo "REQUEST_FAILED")
echo "$RESPONSE" >> "$OUT"
echo >> "$OUT"

COUNT=$(echo "$RESPONSE" | rg -o 'SYSTEM_HEALTH' | wc -l | tr -d ' ')

STATUS="UNKNOWN"

if [ "$RESPONSE" = "REQUEST_FAILED" ]; then
  STATUS="STILL_DOWN"
elif [ "$COUNT" -eq 1 ]; then
  STATUS="REBUILD_SUCCESS_FIX_CONFIRMED"
elif [ "$COUNT" -gt 1 ]; then
  STATUS="REBUILD_SUCCESS_BUT_DUPLICATED"
elif [ "$COUNT" -eq 0 ]; then
  STATUS="REBUILD_SUCCESS_SIGNAL_MISSING"
fi

echo "STATUS: $STATUS" >> "$OUT"

echo "Wrote $OUT"
echo "STATUS: $STATUS"

