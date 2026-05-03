#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8080}"

echo "== Phase 64 agent signal audit =="
echo "BASE_URL=$BASE_URL"
echo

echo "-- repo scan: candidate files"
find . \
  \( -path './node_modules' -o -path './.git' -o -path './dist' \) -prune -o \
  -type f \
  \( -name '*.js' -o -name '*.mjs' -o -name '*.ts' -o -name '*.html' \) \
  -print | sort | grep -E 'tasks|task|delegat|agent|run|events|dashboard|bundle' || true

echo
echo "-- repo scan: named-agent strings"
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  -E 'Matilda|Atlas|Cade|Effie' \
  . || true

echo
echo "-- repo scan: actor/agent ownership fields"
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  -E 'actor|agent_id|agentId|agent_name|agentName|assigned_agent|assignedAgent|owner|run_id|task_id|taskId' \
  . || true

echo
echo "-- live api/tasks"
curl -fsS "$BASE_URL/api/tasks?limit=20" | python3 -m json.tool || true

echo
echo "-- live api/runs"
curl -fsS "$BASE_URL/api/runs?limit=20" | python3 -m json.tool || true

echo
echo "-- live task-events endpoint headers"
curl -fsSI "$BASE_URL/events/task-events" || true

echo
echo "-- target question"
echo "Find where named agent attribution should be emitted so Agent Pool can transition IDLE -> ACTIVE using Matilda/Atlas/Cade/Effie instead of generic actor values like policy.probe."
