
#!/usr/bin/env bash

set -euo pipefail

REPORT="RETRY_OF_PAYLOAD_META_RESTORE.txt"

python3 - << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text(encoding="utf-8")

old = '''      const retryOfRaw = t.retry_of_task_id || (t.meta && t.meta.retry_of_task_id) || (t.execution_meta && t.execution_meta.retry_of_task_id) || "";'''

new = '''      const retryOfRaw = t.retry_of_task_id || (t.meta && t.meta.retry_of_task_id) || (t.payload && t.payload.meta && t.payload.meta.retry_of_task_id) || (t.execution_meta && t.execution_meta.retry_of_task_id) || "";'''

if old not in text:

    raise SystemExit("retry_of extraction target not found; refusing patch")

path.write_text(text.replace(old, new, 1), encoding="utf-8")

PY

{

  echo "===== RETRY_OF PAYLOAD META RESTORE ====="

  date

  echo

  git diff -- public/js/phase530_visible_panels_bridge.js

} | tee "$REPORT"

docker compose build dashboard

docker compose up -d dashboard

sleep 2

echo "===== VERIFY /api/tasks STILL HEALTHY =====" | tee -a "$REPORT"

curl -sS "http://localhost:8080/api/tasks?limit=5" | tee -a "$REPORT" | python3 -m json.tool

echo "===== DASHBOARD HEALTH =====" | tee -a "$REPORT"

curl -i http://localhost:8080/api/tasks/health | tee -a "$REPORT"

git add public/js/phase530_visible_panels_bridge.js restore-retry-of-from-payload-meta.sh "$REPORT"

git commit -m "Restore retry relationship from payload metadata"

git push

