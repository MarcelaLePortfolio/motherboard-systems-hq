#!/usr/bin/env bash
set -euo pipefail

: "${BASE_URL:=http://127.0.0.1:8080}"
export BASE_URL
: "${RUN_ID:=run-$(date +%Y%m%d-%H%M%S)}"
export RUN_ID
: "${TASK_ID:=phase36.smoke.task}"
: "${PGC:=motherboard_systems_hq-postgres-1}"

ts_ms() { python3 - <<'PY'
import time
print(int(time.time()*1000))
PY
}

echo "RUN_ID=$RUN_ID"
echo "TASK_ID=$TASK_ID"
echo "PGC=$PGC"
echo "BASE_URL=$BASE_URL"

echo "=== sanity: postgres container exists ==="
docker ps --format '{{.Names}}' | rg -qx "$PGC" || { echo "ERROR: postgres container not running: $PGC"; exit 2; }

echo "=== seed: heartbeat ==="
docker exec -i "$PGC" psql -U postgres -d postgres <<SQL
\pset pager off
INSERT INTO task_events (kind, payload, task_id, ts, run_id, actor)
VALUES ('heartbeat','{}','$TASK_ID', $(ts_ms), '$RUN_ID', 'phase36.smoke');
SQL
echo "=== seed: task.started ==="
docker exec -i "$PGC" psql -U postgres -d postgres <<SQL
\pset pager off
INSERT INTO task_events (kind, payload, task_id, ts, run_id, actor)
VALUES ('task.started','{}','$TASK_ID', $(ts_ms), '$RUN_ID', 'phase36.smoke');
SQL

echo "=== seed: completed (terminal event) ==="
docker exec -i "$PGC" psql -U postgres -d postgres <<SQL
\pset pager off
INSERT INTO task_events (kind, payload, task_id, ts, run_id, actor)
VALUES ('completed','{}','$TASK_ID', $(ts_ms), '$RUN_ID', 'phase36.smoke');
SQL

echo "=== seed: tasks row -> completed (partial unique index-safe) ==="
docker exec -i "$PGC" psql -U postgres -d postgres <<SQL
\pset pager off
INSERT INTO tasks (task_id, title, status, run_id, actor)
VALUES ('$TASK_ID', 'phase36 smoke', 'completed', '$RUN_ID', 'phase36.smoke')
ON CONFLICT (task_id) WHERE task_id IS NOT NULL DO UPDATE
SET status='completed',
    run_id=EXCLUDED.run_id,
    actor=EXCLUDED.actor,
    updated_at=now();
SQL

echo "=== GET $BASE_URL/api/runs/$RUN_ID (expect 200 + is_terminal=true) ==="
curl -sS -D - "$BASE_URL/api/runs/$RUN_ID" | sed -n '1,220p'

echo "=== assert: is_terminal true + task_status completed ==="
python3 - <<'PY'
import json, sys, urllib.request, os
url = os.environ.get("BASE_URL","http://127.0.0.1:8080") + "/api/runs/" + os.environ["RUN_ID"]
data = json.loads(urllib.request.urlopen(url).read().decode("utf-8"))
ok = (data.get("task_status") == "completed") and (data.get("is_terminal") is True) and (data.get("terminal_event_kind") == "completed")
if not ok:
  print("ASSERT_FAIL:", data)
  sys.exit(1)
print("ASSERT_OK")
PY
