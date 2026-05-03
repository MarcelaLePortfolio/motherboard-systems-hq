#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

REPORT="docs/phase487_postgres_recovery_and_dashboard_restore.txt"
RUNTIME_LOG="logs/phase487_dashboard_recovery_runtime.log"

mkdir -p docs logs

{
  echo "PHASE 487 — POSTGRES RECOVERY + DASHBOARD RESTORE"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo
  echo "[1] PRE-RECOVERY DISK"
  df -h .
  echo
  echo "[2] PRE-RECOVERY PORTS"
  lsof -nP -iTCP:5432 -sTCP:LISTEN || true
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  echo
  echo "[3] DOCKER COMPOSE PS"
  docker compose ps || true
  echo
  echo "[4] POSTGRES CONTAINER LOG TAIL"
  docker compose logs --tail=120 postgres || true
  echo
  echo "[5] DASHBOARD CONTAINER LOG TAIL"
  docker compose logs --tail=120 dashboard || true
  echo
} > "$REPORT"

pkill -f 'node server.mjs' 2>/dev/null || true
pkill -f 'tsx .*server' 2>/dev/null || true

docker compose up -d postgres
sleep 5

{
  echo
  echo "[6] POSTGRES AFTER UP"
  docker compose ps postgres || true
  echo
  echo "[7] WAITING FOR POSTGRES READINESS"
} >> "$REPORT"

POSTGRES_CID="$(docker compose ps -q postgres || true)"
if [ -n "${POSTGRES_CID}" ]; then
  for i in $(seq 1 20); do
    if docker exec "$POSTGRES_CID" pg_isready -U postgres >/dev/null 2>&1; then
      echo "postgres ready on attempt $i" >> "$REPORT"
      break
    fi
    echo "postgres not ready on attempt $i" >> "$REPORT"
    sleep 2
  done
fi

{
  echo
  echo "[8] POSTGRES FINAL LOG TAIL"
  docker compose logs --tail=120 postgres || true
  echo
  echo "[9] STARTING LOCAL DASHBOARD SERVER"
} >> "$REPORT"

nohup node server.mjs > "$RUNTIME_LOG" 2>&1 &
sleep 8

{
  echo
  echo "[10] HTTP PROBE"
  curl -I --max-time 10 http://localhost:8080 || true
  echo
  echo "[11] ROOT SNAPSHOT"
  curl -s --max-time 10 http://localhost:8080 | sed -n '1,80p' || true
  echo
  echo "[12] RUNTIME LOG TAIL"
  tail -n 160 "$RUNTIME_LOG" || true
  echo
  echo "[13] FINAL PORTS"
  lsof -nP -iTCP:5432 -sTCP:LISTEN || true
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  echo
  echo "RECOVERY COMPLETE"
} >> "$REPORT"

sed -n '1,320p' "$REPORT"
