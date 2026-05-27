#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

COMPOSE_ARGS=(-f docker-compose.yml)

# Optional workers compose (repo-dependent)
if [[ -f docker-compose.workers.yml ]]; then
  COMPOSE_ARGS+=(-f docker-compose.workers.yml)
fi

# Phase 45.1 stabilization overlay
COMPOSE_ARGS+=(-f docker-compose.phase45_1.startup_determinism.yml)

DASH_URL="${DASH_URL:-http://127.0.0.1:8080/api/runs}"
TIMEOUT_S="${TIMEOUT_S:-60}"

echo "=== compose up (deterministic startup overlay) ==="
docker compose "${COMPOSE_ARGS[@]}" up -d --build

wait_http() {
  local url="$1"
  local timeout_s="$2"
  local start now code
  start="$(date +%s)"
  while true; do
    code="$(curl -sS -o /dev/null -w "%{http_code}" "$url" || true)"
    if [[ "$code" == "200" ]]; then
      return 0
    fi
    now="$(date +%s)"
    if (( now - start >= timeout_s )); then
      echo "ERROR: readiness gate failed (never got 200) url=$url timeout_s=$timeout_s last_code=$code" >&2
      return 1
    fi
    sleep 1
  done
}

echo
echo "=== dashboard readiness gate: $DASH_URL (timeout ${TIMEOUT_S}s) ==="

if [[ -x scripts/_lib/wait_http.sh ]]; then
  scripts/_lib/wait_http.sh "$DASH_URL" "$TIMEOUT_S"
else
  wait_http "$DASH_URL" "$TIMEOUT_S"
fi

echo
echo "OK: dashboard ready (200)."
