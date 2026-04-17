#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p docs

REPORT="docs/phase488_fast_docker_daemon_probe.txt"

{
  echo "PHASE 488 — FAST DOCKER DAEMON PROBE"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] DOCKER INFO (5s timeout)"
  python3 - << 'PY'
import subprocess
try:
    r = subprocess.run(["docker", "info"], capture_output=True, text=True, timeout=5)
    print("DOCKER_EXIT_CODE", r.returncode)
    out = (r.stdout or "")[:800]
    err = (r.stderr or "")[:800]
    if out.strip():
        print("DOCKER_STDOUT")
        print(out)
    if err.strip():
        print("DOCKER_STDERR")
        print(err)
except subprocess.TimeoutExpired:
    print("DOCKER_INFO_TIMEOUT")
PY
  echo

  echo "[2] HOST PORT 5432"
  lsof -nP -iTCP:5432 -sTCP:LISTEN || echo "PORT_NOT_LISTENING"
  echo

  echo "[3] TCP PROBE 127.0.0.1:5432"
  python3 - << 'PY'
import socket
s = socket.socket()
s.settimeout(2)
try:
    s.connect(("127.0.0.1", 5432))
    print("DB_PORT_OPEN")
except Exception as e:
    print("DB_PORT_CLOSED", e)
finally:
    s.close()
PY
  echo

  echo "[4] WORKER FIXED LOG"
  tail -n 30 logs/phase488_worker_fixed.log 2>/dev/null || echo "NO_WORKER_FIXED_LOG"
  echo

  echo "[5] VERDICT"
  echo "- DOCKER_INFO_TIMEOUT or nonzero exit => docker daemon boundary"
  echo "- PORT_NOT_LISTENING or DB_PORT_CLOSED => postgres host bind boundary"
  echo "- DB_PORT_OPEN => next blocker is worker-side"
} > "$REPORT"

sed -n '1,220p' "$REPORT"
