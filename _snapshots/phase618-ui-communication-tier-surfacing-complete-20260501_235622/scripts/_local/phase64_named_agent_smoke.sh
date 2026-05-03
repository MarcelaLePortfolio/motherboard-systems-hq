#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8080}"

echo "== Phase 64 named-agent smoke =="
echo "BASE_URL=$BASE_URL"
echo

TASK_JSON="$(curl -fsS -X POST "$BASE_URL/api/tasks/create" \
  -H 'Content-Type: application/json' \
  -d '{"title":"phase64 named-agent smoke","agent":"Matilda","source":"phase64.named-agent.smoke"}')"

echo "-- create response"
printf '%s\n' "$TASK_JSON" | python3 -m json.tool

TASK_ID="$(printf '%s' "$TASK_JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("task_id",""))')"

echo
echo "-- task id"
printf '%s\n' "$TASK_ID"

echo
echo "-- latest tasks"
curl -fsS "$BASE_URL/api/tasks?limit=5" | python3 -m json.tool

echo
echo "-- latest runs"
curl -fsS "$BASE_URL/api/runs?limit=10" | python3 -m json.tool

echo
echo "Expected browser result:"
echo "Matilda should flip ACTIVE if named-agent attribution is reaching the live agent pool path."
