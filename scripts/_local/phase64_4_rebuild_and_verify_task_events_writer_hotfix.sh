#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
TMP_DIR="$(mktemp -d)"
TASK_EVENTS_SAMPLE="${TMP_DIR}/task-events.sample"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

docker compose build dashboard
docker compose up -d dashboard
sleep 8

echo "== dashboard health =="
curl -I "${BASE_URL}/dashboard"
echo

echo "== sample /events/task-events for 8s =="
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
        time.sleep(8)
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

open "${BASE_URL}/dashboard?taskeventsfix=$(date +%s)"
printf '%s\n' \
'Hard refresh with Cmd+Shift+R' \
'Then click Task Events.' \
'Console checks:' \
'document.readyState' \
'document.querySelector("[data-tab=\"task-events\"], [data-target=\"task-events\"], button[aria-controls=\"obs-panel-events\"]")?.click()' \
'document.querySelector("[data-tab-panel=\"task-events\"], #task-events-panel, #obs-panel-events")?.outerHTML'
