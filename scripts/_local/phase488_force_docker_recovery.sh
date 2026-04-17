#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p docs

REPORT="docs/phase488_force_docker_recovery.txt"

{
  echo "PHASE 488 — FORCE DOCKER RECOVERY"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] HARD STOP DOCKER PROCESSES"
} > "$REPORT"

pkill -9 -f Docker 2>/dev/null || true
pkill -9 -f com.docker 2>/dev/null || true
sleep 3

{
  echo "Docker processes killed"
  echo
  echo "[2] CLEAN DOCKER SOCKET (IF STALE)"
} >> "$REPORT"

rm -f ~/Library/Containers/com.docker.docker/Data/docker.sock 2>/dev/null || true
rm -f ~/.docker/run/docker.sock 2>/dev/null || true

{
  echo "Socket cleanup attempted"
  echo
  echo "[3] RELAUNCH DOCKER DESKTOP"
} >> "$REPORT"

open -a Docker || true

{
  echo
  echo "[4] WAIT FOR DAEMON (MAX 120s)"
} >> "$REPORT"

python3 - << 'PY' >> "$REPORT" 2>&1
import subprocess, time, sys

deadline = time.time() + 120
attempt = 0

while time.time() < deadline:
    attempt += 1
    try:
        r = subprocess.run(["docker","info"], capture_output=True, text=True, timeout=5)
        print(f"attempt={attempt} exit={r.returncode}")
        if r.returncode == 0:
            print("DOCKER_READY")
            sys.exit(0)
        else:
            print((r.stderr or "")[:300])
    except subprocess.TimeoutExpired:
        print(f"attempt={attempt} TIMEOUT")
    time.sleep(5)

print("DOCKER_NOT_READY")
sys.exit(1)
PY

{
  echo
  echo "[5] VERIFY PORT 5432"
  lsof -nP -iTCP:5432 -sTCP:LISTEN || echo "PORT_NOT_LISTENING"
  echo

  echo "[6] FINAL VERDICT"
  echo "- DOCKER_READY → proceed to restart postgres + dashboard"
  echo "- DOCKER_NOT_READY → requires manual Docker Desktop restart or system reboot"
} >> "$REPORT"

sed -n '1,260p' "$REPORT"
