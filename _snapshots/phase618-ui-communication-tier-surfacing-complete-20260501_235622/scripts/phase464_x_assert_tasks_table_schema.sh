#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_tasks_schema_assertion.txt"

mkdir -p docs

echo "PHASE 464.X — TASKS TABLE SCHEMA ASSERTION" > "$OUT"
echo "==========================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Inspect tasks table structure" >> "$OUT"
docker compose exec -T postgres psql -U postgres -d postgres -c "\d tasks" >> "$OUT" 2>&1 || echo "tasks table not found" >> "$OUT"
echo >> "$OUT"

echo "STEP 2 — Ensure required columns exist" >> "$OUT"

docker compose exec -T postgres psql -U postgres -d postgres <<'SQL' >> "$OUT" 2>&1
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS task_id TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS status TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS payload JSONB;
SQL

echo >> "$OUT"

echo "STEP 3 — Restart dashboard for schema pickup" >> "$OUT"
docker compose restart dashboard >> "$OUT" 2>&1 || true
echo >> "$OUT"

echo "STEP 4 — Wait for boot" >> "$OUT"
sleep 3
echo "Waited 3 seconds" >> "$OUT"
echo >> "$OUT"

echo "STEP 5 — Final endpoint verification" >> "$OUT"
RESPONSE=$(curl -s --max-time 3 http://localhost:3000/api/diagnostics/system-health || echo "REQUEST_FAILED")
echo "$RESPONSE" >> "$OUT"
echo >> "$OUT"

COUNT=$(echo "$RESPONSE" | rg -o 'SYSTEM_HEALTH' | wc -l | tr -d ' ')

STATUS="UNKNOWN"

if [ "$RESPONSE" = "REQUEST_FAILED" ]; then
  STATUS="SERVER_NOT_RESPONDING"
elif [ "$COUNT" -eq 1 ]; then
  STATUS="FULLY_RECOVERED"
elif [ "$COUNT" -gt 1 ]; then
  STATUS="RECOVERED_DUPLICATION_PRESENT"
elif [ "$COUNT" -eq 0 ]; then
  STATUS="RECOVERED_SIGNAL_MISSING"
fi

echo "STATUS: $STATUS" >> "$OUT"

echo "Wrote $OUT"
echo "STATUS: $STATUS"

