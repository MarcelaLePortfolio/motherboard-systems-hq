#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p docs logs

REPORT="docs/phase488_restart_postgres_and_dashboard_after_docker_ready.txt"
LOG="logs/phase488_dashboard_relaunch.log"

{
  echo "PHASE 488 — RESTART POSTGRES + DASHBOARD AFTER DOCKER READY"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] DOCKER INFO"
  docker info >/dev/null 2>&1 && echo "DOCKER_READY" || echo "DOCKER_NOT_READY"
  echo

  echo "[2] START POSTGRES"
  docker compose up -d postgres || true
  echo
} > "$REPORT"

python3 - << 'PY' >> "$REPORT" 2>&1 || true
import socket, time, sys
deadline = time.time() + 60
attempt = 0
while time.time() < deadline:
    attempt += 1
    s = socket.socket()
    s.settimeout(2)
    try:
        s.connect(("127.0.0.1", 5432))
        print(f"POSTGRES_PORT_OPEN attempt={attempt}")
        sys.exit(0)
    except Exception as e:
        print(f"POSTGRES_WAIT attempt={attempt} err={e}")
        time.sleep(3)
    finally:
        s.close()
print("POSTGRES_NOT_READY")
sys.exit(1)
PY

{
  echo
  echo "[3] HOST PORT 5432"
  lsof -nP -iTCP:5432 -sTCP:LISTEN || echo "PORT_NOT_LISTENING"
  echo

  echo "[4] RESTART DASHBOARD"
} >> "$REPORT"

pkill -f 'node server.mjs' 2>/dev/null || true
sleep 1
nohup node server.mjs > "$LOG" 2>&1 &
sleep 8

{
  echo
  echo "[5] DASHBOARD CHECK"
  curl -I --max-time 5 http://localhost:3000 || true
  echo

  echo "[6] /api/runs SNAPSHOT"
  curl -s --max-time 8 http://localhost:3000/api/runs | head -c 1200 || true
  echo
  echo

  echo "[7] NODE LOG TAIL"
  tail -n 120 "$LOG" || true
  echo

  echo "[8] VERDICT"
  echo "- If localhost:3000 responds, dashboard recovery succeeded"
  echo "- If /api/runs returns JSON, backend + DB corridor is restored"
  echo "- If server log still shows waiting for postgres, DB binding remains incomplete"
} >> "$REPORT"

sed -n '1,320p' "$REPORT"
