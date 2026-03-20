#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8080}"

echo "== Phase 64 named-agent path audit =="
echo "BASE_URL=$BASE_URL"
echo

echo "-- focused source scan (excluding archives/backups)"
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude-dir=_archive \
  --exclude-dir=ts-backup \
  --exclude-dir=scripts_backup_2 \
  --exclude='*.backup*' \
  --exclude='*.bak*' \
  --exclude='import_check.log' \
  -E 'task_id|run_id|actor|agent|assignedAgent|assigned_agent|agentName|agent_name|delegate|delegation|/api/tasks|/api/runs|task_events|emit' \
  server routes public scripts drizzle sql . || true

echo
echo "-- likely current files"
for f in \
  server/tasks-mutations.mjs \
  server/task_events_emit.mjs \
  server/routes/api-tasks-postgres.mjs \
  routes/api/delegate.ts \
  public/js/phase64_agent_activity_wire.js \
  public/js/phase61_recent_history_wire.js
do
  if [[ -f "$f" ]]; then
    echo
    echo "===== FILE: $f ====="
    nl -ba "$f" | sed -n '1,260p'
  fi
done

echo
echo "-- live api/tasks"
curl -fsS "$BASE_URL/api/tasks?limit=20" | python3 -m json.tool || true

echo
echo "-- live api/runs"
curl -fsS "$BASE_URL/api/runs?limit=20" | python3 -m json.tool || true

echo
echo "-- answer target"
echo "Identify the current write path that can stamp a named agent (Matilda/Atlas/Cade/Effie) into task/run/event records."
