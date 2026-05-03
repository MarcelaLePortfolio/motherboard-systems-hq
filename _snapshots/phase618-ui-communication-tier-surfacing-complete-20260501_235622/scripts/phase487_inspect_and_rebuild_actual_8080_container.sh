#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_inspect_and_rebuild_actual_8080_container_${STAMP}.txt"

CONTAINER_ID="$(docker ps --format '{{.ID}} {{.Ports}} {{.Names}}' 2>/dev/null | awk '/0\.0\.0\.0:8080->|:::8080->/ {print $1; exit}')"
CONTAINER_NAME="$(docker ps --format '{{.ID}} {{.Names}}' 2>/dev/null | awk -v id="${CONTAINER_ID}" '$1==id {print $2; exit}')"

{
  echo "PHASE 487 — INSPECT AND REBUILD ACTUAL 8080 CONTAINER"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo "container_id=${CONTAINER_ID:-NONE}"
  echo "container_name=${CONTAINER_NAME:-NONE}"
  echo

  echo "=== HOST ARTIFACT CHECK ==="
  rg -n -C 3 "Confidence: insufficient|Confidence: limited|Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Sources: diagnostics/system-health" public/dashboard.html 2>/dev/null || true
  echo

  if [ -n "${CONTAINER_ID:-}" ]; then
    echo "=== CONTAINER INSPECT ==="
    docker inspect "${CONTAINER_ID}" 2>/dev/null || true
    echo

    echo "=== CONTAINER /app/public/dashboard.html CHECK ==="
    docker exec "${CONTAINER_ID}" sh -lc 'test -f /app/public/dashboard.html && grep -n -C 3 "Confidence: insufficient\|Confidence: limited\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health" /app/public/dashboard.html || true' 2>/dev/null || true
    echo

    echo "=== CONTAINER CWD + APP FILES ==="
    docker exec "${CONTAINER_ID}" sh -lc 'pwd; ls -la /app 2>/dev/null || true; ls -la /app/public 2>/dev/null || true' 2>/dev/null || true
    echo
  fi

  echo "=== DOCKER COMPOSE SERVICES ==="
  docker compose config --services 2>/dev/null || docker-compose config --services 2>/dev/null || true
  echo

  echo "=== DOCKER COMPOSE REBUILD (FORCE) ==="
  docker compose down 2>/dev/null || docker-compose down 2>/dev/null || true
  docker compose build --no-cache 2>&1 || docker-compose build --no-cache 2>&1 || true
  docker compose up -d --force-recreate 2>&1 || docker-compose up -d --force-recreate 2>&1 || true
  echo

  echo "=== POST-REBUILD 8080 CONTAINER ==="
  docker ps --format '{{.ID}} {{.Ports}} {{.Names}}' 2>/dev/null || true
  echo

  NEW_CONTAINER_ID="$(docker ps --format '{{.ID}} {{.Ports}} {{.Names}}' 2>/dev/null | awk '/0\.0\.0\.0:8080->|:::8080->/ {print $1; exit}')"
  if [ -n "${NEW_CONTAINER_ID:-}" ]; then
    echo "=== POST-REBUILD CONTAINER /app/public/dashboard.html CHECK ==="
    docker exec "${NEW_CONTAINER_ID}" sh -lc 'test -f /app/public/dashboard.html && grep -n -C 3 "Confidence: insufficient\|Confidence: limited\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health" /app/public/dashboard.html || true' 2>/dev/null || true
    echo
  fi

  echo "=== HTTP CHECK ==="
  curl -I --max-time 5 http://localhost:8080 2>&1 || echo "localhost:8080 unreachable"
  echo

  echo "=== SERVED BODY CHECK ==="
  curl -s http://localhost:8080 | grep -n -C 3 "Confidence: insufficient\|Confidence: limited\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health" || true
  echo

  echo "=== FINAL READ ==="
  echo "Goal: verify whether the actual 8080-serving container still embeds the stale dashboard artifact."
  echo "If served body still shows Confidence: insufficient after force rebuild, the confidence string is being rendered client-side from bundled JS."
  echo
} > "${OUT}"

echo "${OUT}"
