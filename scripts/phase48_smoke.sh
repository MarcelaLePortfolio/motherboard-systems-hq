#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# Phase 48: dashboard-ready wait helper + minimal enforce-mode behavior proof

DASH_URL="${DASH_URL:-http://127.0.0.1:8080}"
HEALTH_PATH="${HEALTH_PATH:-/api/runs}"
WAIT_S="${WAIT_S:-60}"

echo "=== phase48: compose up (default) ==="
docker compose up -d

echo
echo "=== phase48: wait for dashboard (${DASH_URL}${HEALTH_PATH}) ==="
scripts/_lib/wait_http.sh "${DASH_URL}${HEALTH_PATH}" "${WAIT_S}"

echo
echo "=== phase48: enforce-mode behavioral test (expects block) ==="
scripts/phase48_enforce_test.sh

echo
echo "OK: Phase 48 smoke complete."
