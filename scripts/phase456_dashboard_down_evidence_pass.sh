#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_dashboard_down_evidence.txt"

{
  echo "PHASE 456 — DASHBOARD DOWN EVIDENCE PASS"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== REPO STATE ==="
  pwd
  git rev-parse --abbrev-ref HEAD
  git rev-parse HEAD
  echo
  git status --short || true
  echo

  echo "=== DISK STATE ==="
  df -h .
  echo

  echo "=== DOCKER DESKTOP PROCESSES ==="
  ps aux | grep -i "[d]ocker" || true
  echo

  echo "=== DOCKER CLI INFO ==="
  docker info 2>&1 || true
  echo

  echo "=== DOCKER COMPOSE PS ==="
  docker compose ps 2>&1 || true
  echo

  echo "=== ALL CONTAINERS ==="
  docker ps -a 2>&1 || true
  echo

  echo "=== PORT 8080 LISTENER ==="
  lsof -nP -iTCP:8080 -sTCP:LISTEN 2>&1 || true
  echo

  echo "=== HTTP CHECK localhost:8080 ==="
  curl -I --max-time 5 http://localhost:8080 2>&1 || true
  echo

  echo "=== HTTP CHECK localhost:3000 ==="
  curl -I --max-time 5 http://localhost:3000 2>&1 || true
  echo

  echo "=== DASHBOARD CONTAINER LOG CANDIDATES ==="
  docker ps -a --format '{{.Names}}' 2>/dev/null | grep -i 'dashboard\|motherboard' || true
  echo

  for name in $(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -i 'dashboard\|motherboard' || true); do
    echo "----- LOGS: $name -----"
    docker logs --tail 120 "$name" 2>&1 || true
    echo
  done

  echo "=== COMPOSE FILE CANDIDATES ==="
  find . -maxdepth 3 \( -name 'docker-compose.yml' -o -name 'docker-compose.yaml' -o -name 'compose.yml' -o -name 'compose.yaml' \) -print 2>/dev/null || true
  echo

  echo "=== DASHBOARD FILE TARGETS ==="
  grep -Rni --exclude-dir=node_modules --exclude-dir=.git "Operator Console\|Operator Guidance\|Motherboard Systems" app components src server . 2>/dev/null | head -200 || true
  echo
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
