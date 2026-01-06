#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

have() { command -v "$1" >/dev/null 2>&1; }

run_timeout() {
  local secs="$1"; shift
  if have timeout; then
    timeout "$secs" "$@"
  elif have gtimeout; then
    gtimeout "$secs" "$@"
  else
    perl -e 'alarm shift; exec @ARGV' "$secs" "$@"
  fi
}

echo "────────────────────────────────────────────"
echo " Phase 14.2 — Verify Task Contract"
echo "────────────────────────────────────────────"
echo

git status
echo

docker compose down || true
docker compose up -d --build
echo

curl -fsS http://127.0.0.1:8080/health | (have jq && jq || cat)
curl -fsS http://127.0.0.1:8080/api/tasks | (have jq && jq || cat)
echo

DELEGATE=$(curl -fsS -X POST http://127.0.0.1:8080/api/delegate-task \
  -H "Content-Type: application/json" \
  -d '{"title":"phase14.2 verify","agent":"cade"}')

echo "$DELEGATE" | (have jq && jq || cat)
TASK_ID=$(echo "$DELEGATE" | (have jq && jq -r '.task.id'))

COMPLETE=$(curl -fsS -X POST http://127.0.0.1:8080/api/complete-task \
  -H "Content-Type: application/json" \
  -d "{\"taskId\":\"$TASK_ID\"}")

echo "$COMPLETE" | (have jq && jq || cat)

TASKS=$(curl -fsS http://127.0.0.1:8080/api/tasks)
echo "$TASKS" | (have jq && jq || cat)

if echo "$TASKS" | grep -q '"completed"\|"started"'; then
  echo "❌ legacy status detected"
  exit 1
fi

run_timeout 5 curl -N http://127.0.0.1:8080/events/tasks >/dev/null 2>&1
echo "✅ SSE smoke ok"

docker ps
echo "Done."
