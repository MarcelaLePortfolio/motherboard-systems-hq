
#!/usr/bin/env bash

set -euo pipefail

REPORT="TASK_RESPONSE_BASIC_COLUMN_ENRICHMENT.txt"

python3 - << 'PY'

from pathlib import Path

path = Path("server/routes/api-tasks-postgres.mjs")

text = path.read_text(encoding="utf-8")

old = "SELECT id, task_id, title, status, updated_at"

new = "SELECT id, task_id, title, status, notes, run_id, action_tier, kind, payload, metadata, created_at, updated_at"

if old not in text:

    raise SystemExit("basic select target not found; refusing patch")

path.write_text(text.replace(old, new, 1), encoding="utf-8")

PY

{

  echo "===== BASIC COLUMN TASK RESPONSE ENRICHMENT ====="

  date

  echo

  git diff -- server/routes/api-tasks-postgres.mjs

} | tee "$REPORT"

docker compose build dashboard

docker compose up -d dashboard

sleep 2

echo "===== VERIFY /api/tasks =====" | tee -a "$REPORT"

curl -sS "http://localhost:8080/api/tasks?limit=5" | tee -a "$REPORT" | python3 -m json.tool

echo "===== VERIFY HEALTH =====" | tee -a "$REPORT"

curl -i http://localhost:8080/api/tasks/health | tee -a "$REPORT"

git add server/routes/api-tasks-postgres.mjs enrich-api-tasks-basic-columns.sh "$REPORT"

git commit -m "Enrich task list with basic columns"

git push

