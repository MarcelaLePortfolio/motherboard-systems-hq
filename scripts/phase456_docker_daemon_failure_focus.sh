#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_docker_daemon_failure_focus.txt"

{
  echo "PHASE 456 — DOCKER DAEMON FAILURE FOCUS"
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

  echo "=== DOCKER PROCESS SNAPSHOT ==="
  ps aux | grep -i "[d]ocker" || true
  echo

  echo "=== SOCKET SNAPSHOT ==="
  ls -la "$HOME/.docker/run" 2>/dev/null || true
  echo
  ls -la "$HOME/Library/Containers/com.docker.docker/Data" 2>/dev/null || true
  echo

  echo "=== BACKEND / SUPERVISOR / MONITOR / VM LOG TAILS ==="
  for f in \
    "$HOME/Library/Containers/com.docker.docker/Data/log/host/com.docker.backend.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/host/supervisor.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/host/monitor.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/host/Docker Desktop.stderr.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/host/Docker Desktop.stdout.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/host/docker-desktop.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/host/Docker.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/host/com.docker.virtualization.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/vm/init.log" \
    "$HOME/Library/Containers/com.docker.docker/Data/log/vm/console.log"
  do
    if [ -f "$f" ]; then
      echo "----- TAIL 200: $f -----"
      tail -n 200 "$f" || true
      echo
    fi
  done

  echo "=== RECENT HIGH-SIGNAL ERROR SEARCH ==="
  grep -RniE "fatal|panic|error|failed|unable|exception|crash|socket|docker.sock|vmnetd|virtualization|permission denied|no space left|corrupt|broken|timeout" \
    "$HOME/Library/Containers/com.docker.docker/Data/log" 2>/dev/null | tail -n 500 || true
  echo

  echo "=== MOST RECENT TIMESTAMPED LINES ==="
  find "$HOME/Library/Containers/com.docker.docker/Data/log" -type f 2>/dev/null | while read -r f; do
    echo "----- RECENT: $f -----"
    tail -n 40 "$f" 2>/dev/null || true
    echo
  done
  echo

  echo "=== DOCKER CLI CHECKS ==="
  docker info 2>&1 || true
  echo
  docker context ls 2>&1 || true
  echo
  docker compose ps 2>&1 || true
  echo

  echo "=== DASHBOARD REACHABILITY ==="
  lsof -nP -iTCP:8080 -sTCP:LISTEN 2>&1 || true
  lsof -nP -iTCP:3000 -sTCP:LISTEN 2>&1 || true
  echo
  curl -I --max-time 5 http://localhost:8080 2>&1 || true
  curl -I --max-time 5 http://localhost:3000 2>&1 || true
  echo
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,320p' "$OUT"
