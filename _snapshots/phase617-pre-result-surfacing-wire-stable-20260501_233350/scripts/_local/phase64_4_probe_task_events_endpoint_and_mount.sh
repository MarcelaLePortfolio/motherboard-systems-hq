#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
TMP_DIR="$(mktemp -d)"
OPS_SAMPLE="${TMP_DIR}/ops.sample"
TASK_EVENTS_SAMPLE="${TMP_DIR}/task-events.sample"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "== repo root =="
pwd
echo

echo "== dashboard health =="
curl -I "${BASE_URL}/dashboard"
echo

echo "== search repo for task-events frontend mounts =="
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude='*.map' \
  -E '/events/task-events|task-events|EventSource\(' \
  public server scripts 2>/dev/null || true
echo

echo "== sample /events/ops for 8s =="
python3 - <<'PY' "${BASE_URL}/events/ops" "${OPS_SAMPLE}"
import subprocess
import sys
import time
from pathlib import Path

url = sys.argv[1]
out_path = Path(sys.argv[2])

with out_path.open("wb") as f:
    proc = subprocess.Popen(
        ["curl","-NfsS",url],
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

sed -n '1,80p' "${OPS_SAMPLE}"
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
        ["curl","-NfsS",url],
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

sed -n '1,120p' "${TASK_EVENTS_SAMPLE}"
echo

echo "== event names from /events/task-events =="
grep '^event:' "${TASK_EVENTS_SAMPLE}" | sort | uniq -c || true
echo
