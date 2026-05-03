#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p docs logs

REPORT="docs/phase488_recover_docker_and_dashboard.txt"
LOG="logs/phase488_dashboard_relaunch.log"

{
  echo "PHASE 488 — RECOVER DOCKER + DASHBOARD"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] PRECHECK"
  python3 - << 'PY'
import subprocess

def run(cmd, timeout=5):
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        print("$ " + " ".join(cmd))
        print("exit=", r.returncode)
        if r.stdout.strip():
            print(r.stdout[:1200])
        if r.stderr.strip():
            print(r.stderr[:1200])
        print()
        return r.returncode
    except subprocess.TimeoutExpired:
        print("$ " + " ".join(cmd))
        print("TIMEOUT")
        print()
        return 124

run(["docker", "info"], timeout=5)
run(["lsof", "-nP", "-iTCP:5432", "-sTCP:LISTEN"], timeout=5)
run(["curl", "-I", "--max-time", "5", "http://localhost:3000"], timeout=6)
PY
  echo

  echo "[2] RELAUNCH DOCKER DESKTOP"
} > "$REPORT"

pkill -f Docker 2>/dev/null || true
pkill -f com.docker 2>/dev/null || true
sleep 2
open -a Docker || true

{
  echo "Docker app relaunch requested"
  echo
  echo "[3] WAIT FOR DOCKER DAEMON (up to 90s)"
} >> "$REPORT"

python3 - << 'PY' >> "$REPORT" 2>&1
import subprocess, time, sys

deadline = time.time() + 90
attempt = 0
while time.time() < deadline:
    attempt += 1
    try:
        r = subprocess.run(["docker", "info"], capture_output=True, text=True, timeout=5)
        print(f"attempt={attempt} exit={r.returncode}")
        if r.returncode == 0:
            print("DOCKER_READY")
            sys.exit(0)
        else:
            err = (r.stderr or "").strip()
            if err:
                print(err[:400])
    except subprocess.TimeoutExpired:
        print(f"attempt={attempt} TIMEOUT")
    time.sleep(5)

print("DOCKER_NOT_READY")
sys.exit(1)
PY

{
  echo
  echo "[4] START POSTGRES"
} >> "$REPORT"

docker compose up -d postgres >> "$REPORT" 2>&1 || true
sleep 5

{
  echo
  echo "[5] VERIFY POSTGRES HOST BIND"
  lsof -nP -iTCP:5432 -sTCP:LISTEN || echo "PORT_NOT_LISTENING"
  echo

  echo "[6] RESTART DASHBOARD SERVER"
} >> "$REPORT"

pkill -f 'node server.mjs' 2>/dev/null || true
sleep 1
nohup node server.mjs > "$LOG" 2>&1 &
sleep 8

{
  echo
  echo "[7] VERIFY DASHBOARD"
  curl -I --max-time 5 http://localhost:3000 || true
  echo
  echo "[8] /api/runs SNAPSHOT"
  curl -s --max-time 8 http://localhost:3000/api/runs | head -c 1200 || true
  echo
  echo
  echo "[9] NODE LOG TAIL"
  tail -n 120 "$LOG" || true
  echo
  echo "RECOVERY COMPLETE"
} >> "$REPORT"

sed -n '1,320p' "$REPORT"
