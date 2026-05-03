#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
REPO_ROOT="$(pwd)"
TMP_DIR="$(mktemp -d)"
TASK_EVENTS_SAMPLE="${TMP_DIR}/task-events.sample"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "== repo root =="
echo "${REPO_ROOT}"
echo

echo "== git head =="
git rev-parse --short HEAD
echo

echo "== dashboard health =="
curl -I "${BASE_URL}/dashboard"
echo

echo "== route anchors =="
grep -nE 'router\.get\("/events/task-events"|_sseWrite|cursor|Last-Event-ID|setInterval|while |for \(|SELECT|task_events|ORDER BY|LIMIT' server/routes/task-events-sse.mjs || true
echo

echo "== route excerpt: top =="
sed -n '1,260p' server/routes/task-events-sse.mjs
echo

echo "== route excerpt: tail =="
sed -n '261,520p' server/routes/task-events-sse.mjs
echo

echo "== sample /events/task-events for 5s =="
python3 - <<'PY' "${BASE_URL}/events/task-events" "${TASK_EVENTS_SAMPLE}"
import subprocess
import sys
import time
from pathlib import Path

url = sys.argv[1]
out_path = Path(sys.argv[2])

with out_path.open("wb") as f:
    proc = subprocess.Popen(
        ["curl", "-NfsS", url],
        stdout=f,
        stderr=subprocess.DEVNULL,
    )
    try:
        time.sleep(5)
    finally:
        if proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=2)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()
PY

sed -n '1,80p' "${TASK_EVENTS_SAMPLE}"
echo

echo "== event names from /events/task-events =="
grep '^event:' "${TASK_EVENTS_SAMPLE}" | sort | uniq -c || true
echo

echo "== total ids =="
grep '^id:' "${TASK_EVENTS_SAMPLE}" | wc -l | tr -d ' '
echo

echo "== unique ids =="
grep '^id:' "${TASK_EVENTS_SAMPLE}" | sort | uniq | wc -l | tr -d ' '
echo

echo "== duplicate ids (top 10) =="
grep '^id:' "${TASK_EVENTS_SAMPLE}" | sort | uniq -c | sort -nr | head -10 || true
echo

echo "== route signature hash =="
shasum server/routes/task-events-sse.mjs
