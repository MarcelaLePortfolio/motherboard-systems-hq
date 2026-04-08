#!/usr/bin/env bash
set -euo pipefail

OUT="docs/recovery_full_audit/66_emit_fresh_task_event_and_capture_runtime_followthrough.txt"
PG_CID="motherboard_systems_hq-postgres-1"
DASH_CID="motherboard_systems_hq-dashboard-1"
DB="postgres"
TASK_ID="phase457-test-2"
RUN_ID="run-457b"

{
  echo "PHASE 457P EMIT FRESH TASK EVENT AND CAPTURE RUNTIME FOLLOWTHROUGH"
  echo "================================================================="
  echo
  echo "STEP 1 — INSERT FRESH TASK"
  docker exec "$PG_CID" psql -U postgres -d "$DB" -c "
  INSERT INTO tasks (task_id,status,kind,title,action_tier,run_id)
  VALUES ('$TASK_ID','queued','smoke','Phase457 Fresh Task','observe','$RUN_ID');
  " 2>&1 || true
  echo

  echo "STEP 2 — INSERT FRESH TASK EVENTS"
  docker exec "$PG_CID" psql -U postgres -d "$DB" -c "
  INSERT INTO task_events (task_id,kind,actor,payload,run_id)
  VALUES
    ('$TASK_ID','task.created','phase457','{\"task_id\":\"$TASK_ID\",\"status\":\"queued\",\"kind\":\"task.created\"}','$RUN_ID'),
    ('$TASK_ID','task.updated','phase457','{\"task_id\":\"$TASK_ID\",\"status\":\"running\",\"kind\":\"task.updated\"}','$RUN_ID'),
    ('$TASK_ID','task.completed','phase457','{\"task_id\":\"$TASK_ID\",\"status\":\"completed\",\"kind\":\"task.completed\"}','$RUN_ID');
  " 2>&1 || true
  echo

  echo "STEP 3 — VERIFY DATABASE ROWS"
  docker exec "$PG_CID" psql -U postgres -d "$DB" -c "
  select task_id,status,title,run_id
  from tasks
  where task_id in ('phase457-test','$TASK_ID')
  order by id desc;
  " 2>&1 || true
  echo
  docker exec "$PG_CID" psql -U postgres -d "$DB" -c "
  select task_id,kind,run_id,created_at
  from task_events
  where task_id in ('phase457-test','$TASK_ID')
  order by id desc
  limit 12;
  " 2>&1 || true
  echo

  echo "STEP 4 — VERIFY API TASKS"
  curl -fsSL "http://localhost:8080/api/tasks?limit=20" || true
  echo
  echo

  echo "STEP 5 — CAPTURE EVENT STREAM FOR 4 SECONDS"
  timeout 4 curl -Ns "http://localhost:8080/events/task-events" || true
  echo
  echo

  echo "STEP 6 — DASHBOARD LOG TAIL"
  docker logs "$DASH_CID" --tail 120 2>&1 || true
  echo

  echo "STEP 7 — QUICK RESULT"
  API_HAS_FRESH_TASK=0
  STREAM_HAS_FRESH_TASK=0
  DB_HAS_COMPLETED_EVENT=0

  curl -fsSL "http://localhost:8080/api/tasks?limit=20" | grep -q "$TASK_ID" && API_HAS_FRESH_TASK=1 || true
  timeout 4 curl -Ns "http://localhost:8080/events/task-events" | grep -q "$TASK_ID" && STREAM_HAS_FRESH_TASK=1 || true
  docker exec "$PG_CID" psql -U postgres -d "$DB" -Atqc "
  select 1 from task_events where task_id = '$TASK_ID' and kind = 'task.completed' limit 1;
  " | grep -q 1 && DB_HAS_COMPLETED_EVENT=1 || true

  echo "API_HAS_FRESH_TASK=$API_HAS_FRESH_TASK"
  echo "STREAM_HAS_FRESH_TASK=$STREAM_HAS_FRESH_TASK"
  echo "DB_HAS_COMPLETED_EVENT=$DB_HAS_COMPLETED_EVENT"
  echo
  echo "BROWSER_TARGET=http://localhost:8080/dashboard.html"
  echo "HARD_REFRESH=CMD+SHIFT+R"
} > "$OUT"

sed -n '1,320p' "$OUT"
