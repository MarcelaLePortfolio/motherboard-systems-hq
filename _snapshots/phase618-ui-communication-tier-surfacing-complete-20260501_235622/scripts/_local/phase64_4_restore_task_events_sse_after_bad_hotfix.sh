#!/usr/bin/env bash
set -euo pipefail

BASE_COMMIT="${1:-53547422}"
BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

git checkout "$BASE_COMMIT" -- server/routes/task-events-sse.mjs

docker compose build dashboard
docker compose up -d dashboard
sleep 8

echo "== dashboard health =="
curl -I "${BASE_URL}/dashboard"
echo

echo "== dashboard logs tail =="
docker compose logs --tail=120 dashboard
echo

echo "== task-events endpoint sample =="
python3 - <<'PY' "${BASE_URL}/events/task-events"
import subprocess
import sys
import time

url = sys.argv[1]
proc = subprocess.Popen(
    ["curl", "-NfsS", url],
    stdout=subprocess.PIPE,
    stderr=subprocess.DEVNULL,
    text=True,
)
try:
    time.sleep(3)
finally:
    if proc.poll() is None:
        proc.terminate()
        try:
            proc.wait(timeout=2)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait()

if proc.stdout:
    for _ in range(20):
        line = proc.stdout.readline()
        if not line:
            break
        print(line.rstrip())
PY
echo

echo "restored server/routes/task-events-sse.mjs from ${BASE_COMMIT}"
