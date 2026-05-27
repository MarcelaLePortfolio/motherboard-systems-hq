#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

DASHBOARD_HEALTH_URL="${DASHBOARD_HEALTH_URL:-http://localhost:8080/api/health}"
OUT_DIR="artifacts/operational-closeout"
mkdir -p "$OUT_DIR"

TS="$(date +"%Y%m%d_%H%M%S")"
LOG_FILE="$OUT_DIR/phase80_operational_closeout_${TS}.log"
TAG="v80.0-safe-iteration-engine-golden"

exec > >(tee "$LOG_FILE") 2>&1

wait_for_api() {
  local attempts=45
  local i=1
  while [[ "$i" -le "$attempts" ]]; do
    if curl -sf "$DASHBOARD_HEALTH_URL" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
    i=$((i + 1))
  done
  return 1
}

echo "PHASE 80 — OPERATIONAL CLOSEOUT"
echo "--------------------------------"
echo "generated_at=$(date +"%Y-%m-%d %H:%M:%S")"
echo "repo=$(basename "$ROOT_DIR")"
echo "branch=$(git rev-parse --abbrev-ref HEAD)"
echo "commit=$(git rev-parse --short HEAD)"
echo "dashboard_health_url=$DASHBOARD_HEALTH_URL"

echo ""
echo "STEP 1 — CONTAINER REBUILD"
docker compose build dashboard

echo ""
echo "STEP 2 — CONTAINER RESTART"
docker compose up -d dashboard

echo ""
echo "STEP 3 — CONTAINER STATUS"
docker compose ps

echo ""
echo "STEP 4 — WAIT FOR DASHBOARD HEALTH"
if wait_for_api; then
  echo "dashboard_health=responding"
else
  echo "dashboard_health=not_responding" >&2
  exit 1
fi

echo ""
echo "STEP 5 — SAFE ITERATION ENGINE"
bash scripts/_local/phase80_safe_iteration_engine.sh

echo ""
echo "STEP 6 — FINAL PREFLIGHT"
bash scripts/_local/phase75_operator_preflight.sh

echo ""
echo "STEP 7 — FINAL RISK SURFACE"
bash scripts/_local/phase78_operator_risk_surface.sh

echo ""
echo "STEP 8 — TAG READINESS"
git status --short --branch

echo ""
echo "closeout_log=$LOG_FILE"
echo "tag_ready=$TAG"
echo "PHASE 80 OPERATIONAL CLOSEOUT COMPLETE"
