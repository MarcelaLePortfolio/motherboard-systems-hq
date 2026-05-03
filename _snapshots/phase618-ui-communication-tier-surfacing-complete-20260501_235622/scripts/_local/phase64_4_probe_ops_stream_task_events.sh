#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
TMP_FILE="$(mktemp)"
cleanup() {
  rm -f "$TMP_FILE"
}
trap cleanup EXIT

echo "== repo root =="
pwd
echo

echo "== dashboard health =="
curl -I "${BASE_URL}/dashboard"
echo

echo "== sampling /events/ops for 12s (mac-compatible) =="
python3 - <<'PY' "$BASE_URL" "$TMP_FILE"
import subprocess
import sys
import time
from pathlib import Path

base_url = sys.argv[1]
out_path = Path(sys.argv[2])

with out_path.open("wb") as f:
    proc = subprocess.Popen(
        ["curl", "-NfsS", f"{base_url}/events/ops"],
        stdout=f,
        stderr=subprocess.DEVNULL,
    )
    try:
        time.sleep(12)
    finally:
        if proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=2)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()
PY
echo

echo "== raw sample head =="
sed -n '1,120p' "$TMP_FILE"
echo

echo "== task-event-like lines =="
grep -Ein 'task|run|lease|dispatch|heartbeat|queue|queued|start|started|complete|completed|cancel|cancelled|failed|error|progress' "$TMP_FILE" || true
echo

echo "== event names =="
grep '^event:' "$TMP_FILE" | sort | uniq -c || true
echo

echo "== data payload summary =="
python3 - <<'PY' "$TMP_FILE"
import json
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()

blocks = [b.strip() for b in text.split("\n\n") if b.strip()]
print(f"blocks={len(blocks)}")

interesting = []
for block in blocks:
    event = None
    data_lines = []
    for line in block.splitlines():
        if line.startswith("event:"):
            event = line.split(":", 1)[1].strip()
        elif line.startswith("data:"):
            data_lines.append(line.split(":", 1)[1].strip())
    payload_text = "\n".join(data_lines).strip()
    payload = payload_text
    if payload_text:
        try:
            payload = json.loads(payload_text)
        except Exception:
            pass
    blob = json.dumps(payload, default=str).lower() if not isinstance(payload, str) else payload.lower()
    if re.search(r'task|run|lease|dispatch|heartbeat|queue|queued|start|started|complete|completed|cancel|cancelled|failed|error|progress', blob):
        interesting.append((event, payload))

print(f"interesting_blocks={len(interesting)}")
for idx, (event, payload) in enumerate(interesting[:20], start=1):
    print(f"--- interesting[{idx}] event={event!r}")
    if isinstance(payload, str):
        print(payload[:800])
    else:
        print(json.dumps(payload, indent=2)[:1600])
PY
echo

printf '%s\n' \
'Next browser checks:' \
'open http://127.0.0.1:8080/dashboard' \
'Hard refresh with Cmd+Shift+R' \
'Console:' \
'window.__PHASE61_RECENT_HISTORY_WIRE && window.__PHASE61_RECENT_HISTORY_WIRE.refreshAll()' \
'document.querySelector("[data-tab-panel=\"task-events\"], #task-events-panel, #obs-panel-events")?.outerHTML'
