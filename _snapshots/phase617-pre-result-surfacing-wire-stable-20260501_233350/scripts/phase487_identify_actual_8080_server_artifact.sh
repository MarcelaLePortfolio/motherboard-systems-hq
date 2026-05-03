#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_identify_actual_8080_server_artifact_${STAMP}.txt"

PID_8080="$(lsof -tiTCP:8080 -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"

{
  echo "PHASE 487 — IDENTIFY ACTUAL 8080 SERVER ARTIFACT"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo "pid_8080=${PID_8080:-NONE}"
  echo

  echo "=== SERVED VS PUBLIC VERDICT SNAPSHOT ==="
  LATEST_VERDICT="$(ls -t docs/phase487_served_vs_public_dashboard_verdict_*.txt 2>/dev/null | head -n 1 || true)"
  if [ -n "${LATEST_VERDICT}" ]; then
    awk '/=== VERDICT ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST_VERDICT}" || true
  else
    echo "No served-vs-public verdict doc found"
  fi
  echo

  echo "=== PORT 8080 OWNER ==="
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  echo

  if [ -n "${PID_8080}" ]; then
    echo "=== PROCESS DETAILS ==="
    ps -fp "${PID_8080}" || true
    echo

    echo "=== FULL COMMAND LINE ==="
    ps -o command= -p "${PID_8080}" || true
    echo

    echo "=== OPEN FILES / CWD ==="
    lsof -p "${PID_8080}" 2>/dev/null | head -n 300 || true
    echo

    echo "=== EXECUTABLE LINKS ==="
    ls -l "/proc/${PID_8080}/cwd" "/proc/${PID_8080}/exe" 2>/dev/null || true
    echo
  fi

  echo "=== EXPRESS / STATIC / DASHBOARD ENTRYPOINT SEARCH ==="
  rg -n -C 4 "express\\(|app\\.use\\(|express\\.static|sendFile\\(|public/dashboard\\.html|listen\\(8080|PORT=8080|process\\.env\\.PORT" . \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' || true
  echo

  echo "=== NEXT READ ==="
  echo "Goal: identify the exact server process and the exact file/artifact it serves on port 8080."
  echo "Next step will patch or restart that exact serving surface only."
  echo
} > "${OUT}"

echo "${OUT}"
