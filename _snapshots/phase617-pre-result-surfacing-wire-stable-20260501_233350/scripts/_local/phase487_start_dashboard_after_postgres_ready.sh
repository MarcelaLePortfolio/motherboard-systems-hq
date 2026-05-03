#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

mkdir -p docs logs

REPORT="docs/phase487_postgres_gate_startup_report.txt"
RUNTIME_LOG="logs/phase487_dashboard_recovery_runtime.log"

{
  echo "PHASE 487 — POSTGRES-GATED DASHBOARD STARTUP"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo
  echo "[1] DISK"
  df -h .
  echo
  echo "[2] DOCKER HEALTH"
  docker version || true
  docker info >/dev/null 2>&1 && echo "docker info: ok" || echo "docker info: failed"
  echo
  echo "[3] COMPOSE STATUS BEFORE"
  docker compose ps || true
  echo
  echo "[4] PORTS BEFORE"
  lsof -nP -iTCP:5432 -sTCP:LISTEN || true
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  echo
} > "$REPORT"

pkill -f 'node server.mjs' 2>/dev/null || true
pkill -f 'tsx .*server' 2>/dev/null || true

if docker info >/dev/null 2>&1; then
  docker compose up -d postgres >> "$REPORT" 2>&1 || true
  POSTGRES_CID="$(docker compose ps -q postgres || true)"

  if [ -n "${POSTGRES_CID}" ]; then
    READY=0
    for i in $(seq 1 30); do
      if docker exec "$POSTGRES_CID" pg_isready -U postgres >/dev/null 2>&1; then
        echo "postgres ready on attempt $i" >> "$REPORT"
        READY=1
        break
      fi
      echo "postgres not ready on attempt $i" >> "$REPORT"
      sleep 2
    done

    if [ "$READY" -ne 1 ]; then
      {
        echo
        echo "[FAIL] POSTGRES NEVER BECAME READY"
        echo
        echo "[5] POSTGRES LOG TAIL"
        docker compose logs --tail=160 postgres || true
      } >> "$REPORT"
      sed -n '1,320p' "$REPORT"
      exit 1
    fi
  else
    {
      echo
      echo "[FAIL] POSTGRES CONTAINER ID MISSING"
    } >> "$REPORT"
    sed -n '1,320p' "$REPORT"
    exit 1
  fi
else
  {
    echo
    echo "[FAIL] DOCKER DAEMON UNAVAILABLE"
  } >> "$REPORT"
  sed -n '1,320p' "$REPORT"
  exit 1
fi

nohup node server.mjs > "$RUNTIME_LOG" 2>&1 &
sleep 8

{
  echo
  echo "[6] HTTP AFTER START"
  curl -I --max-time 10 http://localhost:8080 || true
  echo
  echo "[7] ROOT SNAPSHOT"
  curl -s --max-time 10 http://localhost:8080 | sed -n '1,80p' || true
  echo
  echo "[8] NODE RUNTIME LOG TAIL"
  tail -n 200 "$RUNTIME_LOG" || true
  echo
  echo "[9] COMPOSE STATUS AFTER"
  docker compose ps || true
  echo
  echo "[10] PORTS AFTER"
  lsof -nP -iTCP:5432 -sTCP:LISTEN || true
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  echo
  echo "STARTUP COMPLETE"
} >> "$REPORT"

sed -n '1,320p' "$REPORT"
