#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

mkdir -p logs docs

REPORT="docs/phase487_dashboard_down_recovery_report.txt"
RUNTIME_LOG="logs/phase487_dashboard_recovery_runtime.log"

{
  echo "PHASE 487 — DASHBOARD DOWN RECOVERY"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo
  echo "[1] DISK"
  df -h .
  echo
  echo "[2] GIT STATUS"
  git status --short || true
  echo
  echo "[3] PORT CHECK"
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  lsof -nP -iTCP:3000 -sTCP:LISTEN || true
  echo
  echo "[4] PROCESS CHECK"
  ps aux | grep -E 'server\.mjs|node .*server|tsx .*server' | grep -v grep || true
  echo
  echo "[5] HTTP CHECK BEFORE RECOVERY"
  curl -I --max-time 5 http://localhost:8080 || true
  echo
} > "$REPORT"

if ! curl -fsS --max-time 5 http://localhost:8080 >/dev/null 2>&1; then
  pkill -f 'server\.mjs' 2>/dev/null || true
  pkill -f 'node .*server' 2>/dev/null || true
  pkill -f 'tsx .*server' 2>/dev/null || true

  nohup node server.mjs > "$RUNTIME_LOG" 2>&1 &
  sleep 6
fi

{
  echo
  echo "[6] HTTP CHECK AFTER RECOVERY"
  curl -I --max-time 5 http://localhost:8080 || true
  echo
  echo "[7] ROOT SNAPSHOT"
  curl -s --max-time 5 http://localhost:8080 | sed -n '1,80p' || true
  echo
  echo "[8] RUNTIME LOG TAIL"
  tail -n 120 "$RUNTIME_LOG" 2>/dev/null || true
  echo
  echo "[9] FINAL PORT CHECK"
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  echo
  echo "RECOVERY COMPLETE"
} >> "$REPORT"

sed -n '1,260p' "$REPORT"
