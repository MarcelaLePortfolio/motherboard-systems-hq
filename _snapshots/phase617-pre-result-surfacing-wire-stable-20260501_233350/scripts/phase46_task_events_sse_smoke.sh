#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8080}"
BASE="http://127.0.0.1:${PORT}"

echo "=== Phase 46 smoke: task_events SSE ==="
echo "BASE=$BASE"

echo
echo "=== ensure stack up ==="
docker compose up -d --build >/dev/null
sleep 2

echo
echo "=== 1) alias endpoint returns 307 w/ Location: /events/task-events ==="
HDRS="$(curl -sS -D- --max-time 2 "${BASE}/api/task-events-sse" -o /dev/null || true)"
echo "$HDRS" | sed -n '1,20p'
echo "$HDRS" | head -n 1 | rg -q ' 307 ' || { echo "ERR: expected 307 from /api/task-events-sse" >&2; exit 10; }
echo "$HDRS" | rg -q '^Location:\s*/events/task-events\s*$' || { echo "ERR: expected Location: /events/task-events" >&2; exit 11; }

echo
echo "=== 2) canonical endpoint streams hello within 2s ==="
OUT="$(curl -sS -N 2>/dev/null --max-time 2 "${BASE}/events/task-events" | head -n 8 || true)"
printf "%s\n" "$OUT"
printf "%s\n" "$OUT" | rg -q '^event:\s*hello' || { echo "ERR: expected SSE hello event" >&2; exit 12; }
printf "%s\n" "$OUT" | rg -q '"kind"\s*:\s*"task-events"' || { echo "ERR: expected kind=task-events in hello payload" >&2; exit 13; }

echo
echo "=== 3) postgres logs: ensure old failure signatures are absent ==="
BAD_RE='invalid input syntax for type uuid: "0"|syntax error at or near "order"|where created_at >\s*$|function max\(uuid\)|max\(id\)\s+as\s+max_id|::uuid::uuid'
if docker logs --tail 400 motherboard_systems_hq-postgres-1 2>/dev/null | rg -n "$BAD_RE" ; then
  echo "ERR: found forbidden postgres log signature(s) above" >&2
  exit 14
fi
echo "OK: no forbidden postgres signatures detected"

echo
echo "OK: phase46_task_events_sse_smoke passed"
