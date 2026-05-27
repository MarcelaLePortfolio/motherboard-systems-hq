#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

echo "────────────────────────────────────────────"
echo " Phase 14.1 — Task Contract Smoke Checks"
echo "────────────────────────────────────────────"
echo

BASE="http://127.0.0.1:8080"

echo "1) GET /api/tasks"
curl -fsS "$BASE/api/tasks" | head -c 800 || true
echo
echo

echo "2) Delegate a task (best-effort; endpoint may vary)"
set +e
echo "→ Trying POST /api/delegate-task"
curl -fsS -X POST "$BASE/api/delegate-task" \
  -H "Content-Type: application/json" \
  -d '{"title":"Phase 14.1 contract smoke","agent":"cade","notes":"created by phase14_1_task_contract.sh"}' \
  | head -c 800
RC=$?
set -e

if [ "$RC" -ne 0 ]; then
  echo
  echo "⚠️ /api/delegate-task failed. Trying legacy POST /api/tasks."
  set +e
  curl -fsS -X POST "$BASE/api/tasks" \
    -H "Content-Type: application/json" \
    -d '{"title":"Phase 14.1 contract smoke","agent":"cade","notes":"created by phase14_1_task_contract.sh"}' \
    | head -c 800
  set -e
fi
echo
echo

echo "3) GET /api/tasks (after delegate)"
curl -fsS "$BASE/api/tasks" | head -c 1200 || true
echo
echo

echo "4) SSE sanity (3s) — /events/tasks"
( timeout 3 curl -N "$BASE/events/tasks" || true ) | head -c 600 || true
echo
echo
echo "Done."
