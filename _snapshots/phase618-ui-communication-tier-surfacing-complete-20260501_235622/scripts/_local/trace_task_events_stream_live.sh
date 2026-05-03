#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H2_TASK_EVENTS_STREAM_LIVE_TRACE.txt"

{
  echo "PHASE 489 — H2 TASK EVENTS STREAM LIVE TRACE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== INTERPRETATION ==="
  echo "Task Events client is now mounting and opening, but no events are arriving."
  echo "This means we are past UI wiring failure and now checking stream content."
  echo

  echo "=== TASK EVENTS SSE HEADERS ==="
  curl -i -s --max-time 3 http://localhost:8080/events/task-events | sed -n '1,60p' || true
  echo

  echo "=== TASK EVENTS SSE FRAMES (6s) ==="
  python3 - <<'PY'
import subprocess, time, sys
cmd = ["curl", "-N", "-s", "--max-time", "6", "http://localhost:8080/events/task-events"]
proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
for line in proc.stdout:
    sys.stdout.write(line)
    sys.stdout.flush()
PY
  echo
  echo

  echo "=== TASK EVENTS ROUTE SNIPPET ==="
  grep -n "task-events" "$ROOT/server/routes/task-events-sse.mjs" || true
  sed -n '1,260p' "$ROOT/server/routes/task-events-sse.mjs" 2>/dev/null || true
  echo

  echo "=== TASK MUTATION ROUTES (EVENT PRODUCTION PATH) ==="
  grep -RInE 'dbDelegateTask|dbCompleteTask|task event|task-events|emit.*task|broadcast.*task' "$ROOT/server" \
    --include="*.js" --include="*.mjs" --include="*.ts" || true
  echo

  echo "=== CURRENT TASK ROWS ==="
  curl -s http://localhost:8080/api/tasks | sed -n '1,120p' || true
  echo
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
