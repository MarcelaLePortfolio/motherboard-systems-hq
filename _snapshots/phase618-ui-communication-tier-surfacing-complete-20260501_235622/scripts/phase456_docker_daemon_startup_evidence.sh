#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_docker_daemon_startup_evidence.txt"

{
  echo "PHASE 456 — DOCKER DAEMON STARTUP EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== PRECHECK ==="
  df -h .
  echo
  git rev-parse --abbrev-ref HEAD
  git rev-parse HEAD
  echo
  git status --short || true
  echo

  echo "=== DOCKER DESKTOP PROCESS SNAPSHOT ==="
  ps aux | grep -i "[d]ocker" || true
  echo

  echo "=== SOCKET DIRECTORY SNAPSHOT ==="
  ls -la "$HOME/.docker" 2>/dev/null || true
  echo
  ls -la "$HOME/.docker/run" 2>/dev/null || true
  echo
  ls -la "$HOME/Library/Containers/com.docker.docker/Data" 2>/dev/null || true
  echo

  echo "=== DOCKER DESKTOP APP SUPPORT SNAPSHOT ==="
  ls -la "$HOME/Library/Containers/com.docker.docker/Data/log" 2>/dev/null || true
  echo
  find "$HOME/Library/Containers/com.docker.docker/Data/log" -maxdepth 2 -type f 2>/dev/null | sort || true
  echo

  echo "=== RECENT DOCKER DESKTOP LOG TAILS ==="
  for f in \
    "$HOME/Library/Containers/com.docker.docker/Data/log/host/com.docker.backend.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/host/backend.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/host/monitor.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/vm/init.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/vm/console.log"
  do
    if [ -f "$f" ]; then
      echo "----- TAIL: $f -----"
      tail -n 120 "$f" || true
      echo
    fi
  done

  echo "=== SEARCH FOR SOCKET / DAEMON / ERROR SIGNALS ==="
  grep -RniE "docker.sock|socket|daemon|fatal|panic|error|failed|unable|no space left|permission denied" \
    "$HOME/Library/Containers/com.docker.docker/Data/log" 2>/dev/null | tail -n 300 || true
  echo

  echo "=== DOCKER CLI CHECKS ==="
  docker info 2>&1 || true
  echo
  docker context ls 2>&1 || true
  echo
  docker compose ps 2>&1 || true
  echo

  echo "=== HTTP / PORT CHECKS ==="
  lsof -nP -iTCP:8080 -sTCP:LISTEN 2>&1 || true
  lsof -nP -iTCP:3000 -sTCP:LISTEN 2>&1 || true
  echo
  curl -I --max-time 5 http://localhost:8080 2>&1 || true
  curl -I --max-time 5 http://localhost:3000 2>&1 || true
  echo
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
