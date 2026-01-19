#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

TS="$(date +%s)"
LOG="tmp/phase31_6_recent_tasks_debug.${TS}.log"
SSE="tmp/task-events-sse.${TS}.log"
GREP1="tmp/recent-tasks-grep.${TS}.txt"
GREP2="tmp/task-events-wiring-grep.${TS}.txt"
PSLOG="tmp/compose-ps.${TS}.txt"

compose() { docker compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.worker.yml "$@"; }

compose up -d postgres dashboard --scale worker=0

compose ps | tee "$PSLOG" >/dev/null

curl -sS -I http://127.0.0.1:8080
 | tee -a "$LOG" >/dev/null

set +e
curl -sS -N --max-time 6 -H "Accept: text/event-stream" "http://127.0.0.1:8080/events/task-events
" >"$SSE"
curl_rc=$?
set -e
echo "curl_task_events_rc=$curl_rc sse_log=$SSE" | tee -a "$LOG" >/dev/null

echo "=== worker scale (expect 0) ===" | tee -a "$LOG" >/dev/null
compose ps worker 2>/dev/null | tee -a "$LOG" >/dev/null || true
compose ps --services --status running | rg -n '^worker$' >/dev/null 2>&1 && echo "worker_running=1 (unexpected)" | tee -a "$LOG" >/dev/null || echo "worker_running=0 (expected)" | tee -a "$LOG" >/dev/null

echo "=== find Recent Tasks renderer ===" | tee -a "$LOG" >/dev/null
rg -n --hidden --glob '!/node_modules/' --glob '!/.git/'
'(Recent Tasks|recent[-_ ]tasks|recentTasks|renderRecent|tasks-table|TaskEvents|task-events|/events/task-events|EventSource(|connectSSE|SSE)'
public server 2>/dev/null | tee "$GREP1" >/dev/null

echo "=== focus task-events wiring in dashboard JS ===" | tee -a "$LOG" >/dev/null
rg -n --hidden --glob '!/node_modules/' --glob '!/.git/'
'(/events/task-events|task-events|task.event|task_events|taskEvents|TaskEvents|cursor|heartbeat|EventSource(|addEventListener(|message|event:)'
public/js public/scripts public/.js public/.html 2>/dev/null | tee "$GREP2" >/dev/null

echo "logs:"
echo " $LOG"
echo " $SSE"
echo " $GREP1"
echo " $GREP2"
echo " $PSLOG"
