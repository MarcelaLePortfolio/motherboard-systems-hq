#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

WT_BASE="../mbhq_recovery_visual_compare"

TARGETS=(
  "phase65_layout|8081|mbhq_phase65_layout"
  "phase65_wiring|8082|mbhq_phase65_wiring"
  "operator_guidance|8083|mbhq_operator_guidance"
)

SUMMARY="docs/recovery_full_audit/24_force_relaunch_recovery_compare.txt"

{
  echo "PHASE 457 - FORCE RELAUNCH RECOVERY COMPARE"
  echo "==========================================="
  echo
} > "$SUMMARY"

for item in "${TARGETS[@]}"; do
  NAME="${item%%|*}"
  REST="${item#*|}"
  PORT="${REST%%|*}"
  PROJECT="${REST##*|}"
  WT_PATH="$WT_BASE/$NAME"
  LOG="docs/recovery_full_audit/${NAME}_force_relaunch_port_${PORT}.txt"

  (
    echo "===== $NAME ====="
    cd "$WT_PATH"

    cat > docker-compose.phase457.override.yml <<OVERRIDE
services:
  postgres:
    ports: []
  dashboard:
    ports:
      - "${PORT}:3000"
OVERRIDE

    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      down -v --remove-orphans || true

    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      up --build -d

    sleep 10

    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      ps -a

    curl -I --max-time 10 "http://localhost:${PORT}" || true

  ) > "$LOG" 2>&1 || true

done

echo "DONE"
