#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

WT_BASE="../mbhq_recovery_visual_compare"
SUMMARY="docs/recovery_full_audit/24_force_relaunch_recovery_compare.txt"

TARGETS=(
  "phase65_layout|8081|mbhq_phase65_layout"
  "phase65_wiring|8082|mbhq_phase65_wiring"
  "operator_guidance|8083|mbhq_operator_guidance"
)

{
  echo "PHASE 457 - FORCE RELAUNCH RECOVERY COMPARE"
  echo "==========================================="
  echo
  echo "PURPOSE"
  echo "Force-stop and relaunch each recovery candidate with dashboard host ports only."
  echo
} > "$SUMMARY"

for item in "${TARGETS[@]}"; do
  NAME="${item%%|*}"
  REST="${item#*|}"
  PORT="${REST%%|*}"
  PROJECT="${REST##*|}"
  WT_PATH="$WT_BASE/$NAME"
  LOG="$ROOT/docs/recovery_full_audit/${NAME}_force_relaunch_port_${PORT}.txt"

  {
    echo "===== $NAME ====="
    echo "WORKTREE=$WT_PATH"
    echo "PROJECT=$PROJECT"
    echo "PORT=$PORT"
    echo

    cd "$WT_PATH"

    cat > docker-compose.phase457.override.yml <<OVERRIDE
services:
  postgres:
    ports: []
  dashboard:
    ports:
      - "${PORT}:3000"
OVERRIDE

    echo "--- compose down ---"
    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      down -v --remove-orphans || true
    echo

    echo "--- compose up ---"
    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      up --build -d
    echo

    echo "--- sleep ---"
    sleep 10
    echo

    echo "--- compose ps -a ---"
    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      ps -a || true
    echo

    echo "--- dashboard logs ---"
    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      logs dashboard --tail=80 || true
    echo

    echo "--- postgres logs ---"
    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      logs postgres --tail=80 || true
    echo

    echo "--- http head ---"
    curl -I --max-time 10 "http://localhost:${PORT}" || true
    echo

    echo "--- port listen ---"
    lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN || true
    echo
  } > "$LOG" 2>&1 || true

  {
    echo "NAME=$NAME"
    echo "URL=http://localhost:${PORT}"
    echo "LOG=docs/recovery_full_audit/${NAME}_force_relaunch_port_${PORT}.txt"
    echo
  } >> "$SUMMARY"
done

{
  echo "NEXT"
  echo "Open 8081 / 8082 / 8083 after confirming listeners exist in the logs above."
} >> "$SUMMARY"

echo "DONE"
