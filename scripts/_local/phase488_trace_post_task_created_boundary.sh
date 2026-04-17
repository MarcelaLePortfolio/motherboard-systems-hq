#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

REPORT="docs/phase488_trace_post_task_created_boundary.txt"
mkdir -p docs

{
  echo "PHASE 488 — TRACE POST task.created BOUNDARY"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] SAMPLE /api/runs (confirm created state)"
  curl -s http://localhost:3000/api/runs | head -n 40 || true
  echo

  echo "[2] SAMPLE /events/task-events (8s window)"
} > "$REPORT"

python3 - << 'PY' >> "$REPORT" 2>&1 || true
import urllib.request, time
url = "http://localhost:3000/events/task-events"
req = urllib.request.Request(url, headers={"Accept": "text/event-stream"})
start = time.time()
count = 0
try:
    with urllib.request.urlopen(req, timeout=8) as resp:
        for raw in resp:
            line = raw.decode("utf-8", errors="replace").rstrip("\n")
            print(line)
            count += 1
            if time.time() - start > 8 or count >= 80:
                break
except Exception as e:
    print(f"TASK_EVENTS_CAPTURE_ERROR: {e}")
PY

{
  echo
  echo "[3] SEARCH: task.created EMISSION SOURCE"
  grep -Rni "task.created" server src 2>/dev/null || true
  echo

  echo "[4] SEARCH: task.started / task.completed"
  grep -RniE "task.started|task.completed|task.failed" server src 2>/dev/null || true
  echo

  echo "[5] SEARCH: EXECUTOR / WORKER LOOP"
  grep -RniE "executor|worker|processTask|runTask|taskRunner" server src 2>/dev/null || true
  echo

  echo "[6] SEARCH: EVENT EMIT AFTER CREATION"
  grep -RniE "emit.*task|task_events_emit|publish.*task" server src 2>/dev/null || true
  echo

  echo "[7] NODE LOG (recent)"
  tail -n 120 logs/phase487_runtime_resume.log 2>/dev/null || true
  echo

  echo "[8] SUMMARY TARGET"
  echo "- Confirm where task.created is emitted"
  echo "- Check if any transition events exist in code"
  echo "- Check if executor loop exists"
  echo "- Check if emit stops after creation"
  echo

  echo "TRACE COMPLETE"
} >> "$REPORT"

sed -n '1,260p' "$REPORT"
