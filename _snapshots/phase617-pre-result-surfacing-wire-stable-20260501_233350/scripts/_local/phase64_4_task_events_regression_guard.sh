#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
SAMPLE_SECS="${SAMPLE_SECS:-5}"
TMP_DIR="$(mktemp -d)"
TASK_EVENTS_SAMPLE="${TMP_DIR}/task-events.sample"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "== dashboard health =="
curl -fsSI "${BASE_URL}/dashboard"
echo

echo "== sampling /events/task-events for ${SAMPLE_SECS}s =="
python3 - <<'PY' "${BASE_URL}/events/task-events" "${TASK_EVENTS_SAMPLE}" "${SAMPLE_SECS}"
import subprocess
import sys
import time
from pathlib import Path

url = sys.argv[1]
out_path = Path(sys.argv[2])
secs = int(sys.argv[3])

with out_path.open("wb") as f:
    proc = subprocess.Popen(
        ["curl", "-NfsS", url],
        stdout=f,
        stderr=subprocess.DEVNULL,
    )
    try:
        time.sleep(secs)
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

echo "== task-events replay guard summary =="
python3 - <<'PY' "${TASK_EVENTS_SAMPLE}"
import sys
from collections import Counter
from pathlib import Path

path = Path(sys.argv[1])
lines = path.read_text().splitlines()

events = Counter()
ids = []
cursor_heartbeats = 0

for line in lines:
    if line.startswith("event:"):
        events[line.split(":", 1)[1].strip()] += 1
    elif line.startswith("id:"):
        ids.append(line.split(":", 1)[1].strip())
    elif line.startswith("data:") and '"cursor":' in line and '"ts":' in line:
        cursor_heartbeats += 1

total_ids = len(ids)
unique_ids = len(set(ids))
task_events = events.get("task.event", 0)
heartbeats = events.get("heartbeat", 0)
hello = events.get("hello", 0)

print(f"hello={hello}")
print(f"task.event={task_events}")
print(f"heartbeat={heartbeats}")
print(f"total_ids={total_ids}")
print(f"unique_ids={unique_ids}")
print(f"cursor_heartbeats={cursor_heartbeats}")

if hello < 1:
    raise SystemExit("FAIL: missing hello event from /events/task-events")

# Healthy idle state: hello + heartbeats, no task.event spam.
if task_events == 0:
    print("PASS: idle stream is healthy (heartbeats only, no replay storm)")
    raise SystemExit(0)

# Healthy active state: some task events, but not the same id replayed excessively.
if unique_ids == 0:
    raise SystemExit("FAIL: task.event emitted without ids")

worst = Counter(ids).most_common(1)[0][1]
ratio = total_ids / max(unique_ids, 1)

print(f"worst_duplicate_count={worst}")
print(f"duplicate_ratio={ratio:.2f}")

if worst > 10 and unique_ids <= 2:
    raise SystemExit("FAIL: replay storm detected (same task-event id repeated excessively)")

if ratio > 5 and total_ids >= 20:
    raise SystemExit("FAIL: suspicious duplicate replay ratio detected in /events/task-events")

print("PASS: task-events stream passed replay guard")
PY
