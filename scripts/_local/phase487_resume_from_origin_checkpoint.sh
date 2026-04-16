#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

mkdir -p docs logs

REPORT="docs/phase487_resume_from_origin_checkpoint.txt"
RUNTIME_LOG="logs/phase487_dashboard_recovery_runtime.log"

{
  echo "PHASE 487 — RESUME FROM ORIGIN CHECKPOINT"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo
  echo "[1] DISK"
  df -h .
  echo
  echo "[2] GIT HEAD"
  git log --oneline -n 3
  echo
  echo "[3] DOCKER HEALTH"
  docker version || true
  docker info >/dev/null 2>&1 && echo "docker info: ok" || echo "docker info: failed"
  echo
  echo "[4] COMPOSE STATUS BEFORE"
  docker compose ps || true
  echo
  echo "[5] PORTS BEFORE"
  lsof -nP -iTCP:5432 -sTCP:LISTEN || true
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  echo
  echo "[6] HTTP BEFORE"
  curl -I --max-time 5 http://localhost:8080 || true
  echo
} > "$REPORT"

pkill -f 'node server.mjs' 2>/dev/null || true
pkill -f 'tsx .*server' 2>/dev/null || true

if docker info >/dev/null 2>&1; then
  docker compose up -d postgres >> "$REPORT" 2>&1 || true
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
  else
    echo "postgres container id missing after compose up" >> "$REPORT"
  fi
else
  echo "docker daemon unavailable; skipped compose recovery" >> "$REPORT"
fi

nohup node server.mjs > "$RUNTIME_LOG" 2>&1 &
sleep 8

{
  echo
  echo "[7] HTTP AFTER"
  curl -I --max-time 10 http://localhost:8080 || true
  echo
  echo "[8] ROOT SNAPSHOT"
  curl -s --max-time 10 http://localhost:8080 | sed -n '1,80p' || true
  echo
  echo "[9] NODE RUNTIME LOG TAIL"
  tail -n 160 "$RUNTIME_LOG" || true
  echo
  echo "[10] COMPOSE STATUS AFTER"
  docker compose ps || true
  echo
  echo "[11] PORTS AFTER"
  lsof -nP -iTCP:5432 -sTCP:LISTEN || true
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  echo
  echo "RESUME COMPLETE"
} >> "$REPORT"

sed -n '1,320p' "$REPORT"
