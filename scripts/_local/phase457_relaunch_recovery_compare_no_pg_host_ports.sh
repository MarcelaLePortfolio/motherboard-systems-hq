#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

WT_BASE="../mbhq_recovery_visual_compare"
OUT="docs/recovery_full_audit/22_recovery_visual_compare_relaunch_no_pg_host_ports.txt"

TARGETS=(
  "phase65_layout|8081|mbhq_phase65_layout|recovery/phase65_layout"
  "phase65_wiring|8082|mbhq_phase65_wiring|recovery/phase65_wiring"
  "operator_guidance|8083|mbhq_operator_guidance|recovery/operator_guidance"
)

mkdir -p docs/recovery_full_audit

for item in "${TARGETS[@]}"; do
  NAME="${item%%|*}"
  REST="${item#*|}"
  PORT="${REST%%|*}"
  REST="${REST#*|}"
  PROJECT="${REST%%|*}"
  BRANCH="${REST##*|}"
  WT_PATH="$WT_BASE/$NAME"

  if [ ! -d "$WT_PATH" ]; then
    git worktree add "$WT_PATH" "$BRANCH"
  fi

  cat > "$WT_PATH/docker-compose.phase457.override.yml" <<OVERRIDE
services:
  dashboard:
    ports:
      - "${PORT}:3000"
  postgres:
    ports: []
OVERRIDE

  (
    cd "$WT_PATH"
    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      down --remove-orphans || true

    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      up --build -d

    sleep 8

    echo "=== $NAME ==="
    echo "WORKTREE=$WT_PATH"
    echo "PROJECT=$PROJECT"
    echo "PORT=$PORT"
    echo
    echo "--- docker compose ps ---"
    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      ps || true
    echo
    echo "--- dashboard logs ---"
    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      logs dashboard --tail=60 || true
    echo
    echo "--- postgres logs ---"
    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      logs postgres --tail=40 || true
    echo
    echo "--- http head ---"
    curl -I --max-time 10 "http://localhost:${PORT}" || true
  ) > "docs/recovery_full_audit/${NAME}_relaunch_port_${PORT}.txt" 2>&1 || true
done

{
  echo "PHASE 457 - RECOVERY VISUAL COMPARE RELAUNCH (NO POSTGRES HOST PORTS)"
  echo "====================================================================="
  echo
  echo "PURPOSE"
  echo "Relaunch all recovery comparison candidates with dashboard host ports only."
  echo "Postgres remains internal to each compose project so 5432 host conflicts cannot block startup."
  echo
  for item in "${TARGETS[@]}"; do
    NAME="${item%%|*}"
    REST="${item#*|}"
    PORT="${REST%%|*}"
    REST="${REST#*|}"
    PROJECT="${REST%%|*}"
    BRANCH="${REST##*|}"
    WT_PATH="$WT_BASE/$NAME"
    echo "NAME=$NAME"
    echo "BRANCH=$BRANCH"
    echo "WORKTREE=$WT_PATH"
    echo "PROJECT=$PROJECT"
    echo "URL=http://localhost:${PORT}"
    echo "LOG=docs/recovery_full_audit/${NAME}_relaunch_port_${PORT}.txt"
    echo "OVERRIDE=$WT_PATH/docker-compose.phase457.override.yml"
    echo
  done
  echo "DETERMINISTIC EXPECTATION"
  echo "If the original failure was host port 5432 contention, these launches should now start."
} > "$OUT"

open "http://localhost:8081" || true
open "http://localhost:8082" || true
open "http://localhost:8083" || true

echo "WROTE=$OUT"
sed -n '1,240p' "$OUT"
