#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

echo "== recent dashboard logs =="
docker logs --tail 120 motherboard_systems_hq-dashboard-1 || true

echo
echo "== sample /events/ops stream =="
python3 - <<'PY'
import urllib.request
import sys

url = "http://127.0.0.1:8080/events/ops"
req = urllib.request.Request(url, headers={"Accept": "text/event-stream"})
try:
    with urllib.request.urlopen(req, timeout=10) as r:
        for i in range(40):
            line = r.readline()
            if not line:
                break
            sys.stdout.write(line.decode("utf-8", "replace"))
except Exception as e:
    print(f"[probe-error] {e}")
PY
