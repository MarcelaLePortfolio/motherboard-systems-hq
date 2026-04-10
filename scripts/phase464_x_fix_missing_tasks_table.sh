#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_tasks_table_fix.txt"

mkdir -p docs

echo "PHASE 464.X — FIX: MISSING tasks TABLE" > "$OUT"
echo "======================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Apply minimal safe schema fix (create table if not exists)" >> "$OUT"

docker compose exec -T postgres psql -U postgres -d postgres <<'SQL' >> "$OUT" 2>&1
CREATE TABLE IF NOT EXISTS tasks (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT NOW()
);
SQL

echo >> "$OUT"
echo "STEP 2 — Restart dashboard container" >> "$OUT"
docker compose restart dashboard >> "$OUT" 2>&1 || true
echo >> "$OUT"

echo "STEP 3 — Wait for boot" >> "$OUT"
sleep 3
echo "Waited 3 seconds" >> "$OUT"
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

