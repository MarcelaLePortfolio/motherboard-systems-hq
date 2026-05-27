#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

echo "== Phase 15 Tasks Widget Smoke Check =="
echo "BASE_URL=$BASE_URL"
echo

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need_cmd curl
need_cmd grep
need_cmd sed
need_cmd tr

echo "1) /dashboard should load (HTTP 200) ..."
status="$(curl -sS -o /dev/null -w "%{http_code}" "$BASE_URL/dashboard")"
if [[ "$status" != "200" ]]; then
  echo "FAIL: /dashboard returned HTTP $status" >&2
  exit 1
fi
echo "OK"
echo

echo "2) /api/tasks should return JSON and include tasks array ..."
tasks_json="$(curl -sS "$BASE_URL/api/tasks")"
echo "$tasks_json" | tr -d '\n' | grep -q '"tasks"' || { echo "FAIL: response missing \"tasks\" field" >&2; exit 1; }
echo "$tasks_json" | tr -d '\n' | grep -q '"tasks":[[]' || { echo "FAIL: \"tasks\" is not an array" >&2; exit 1; }
echo "OK"
echo

echo "3) /events/tasks should advertise text/event-stream ..."
hdrs="$(curl -sS -D - -o /dev/null "$BASE_URL/events/tasks" | tr -d '\r')"
echo "$hdrs" | grep -qi '^content-type: text/event-stream' || {
  echo "FAIL: /events/tasks missing Content-Type: text/event-stream" >&2
  echo "--- headers ---" >&2
  echo "$hdrs" >&2
  exit 1
}
echo "OK"
echo

echo "4) /events/tasks should stream at least one 'event:' or 'data:' line within 3s (non-blocking) ..."
stream_sample="$(curl -sS --max-time 3 "$BASE_URL/events/tasks" || true)"
echo "$stream_sample" | tr -d '\r' | grep -Eqi '^(event:|data:)' || {
  echo "WARN: No SSE lines observed in 3s. This can be OK if no heartbeat/event is emitted without changes."
  echo "      If you expect periodic heartbeats, confirm the SSE server is emitting them."
}
echo "OK (or WARN)"
echo

echo "✅ Smoke check complete."
