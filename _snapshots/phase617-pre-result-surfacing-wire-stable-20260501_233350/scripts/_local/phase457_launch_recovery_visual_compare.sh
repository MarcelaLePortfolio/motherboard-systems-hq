#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

WT_BASE="../mbhq_recovery_visual_compare"
OUT="docs/recovery_full_audit/18_recovery_visual_compare_launch.txt"
mkdir -p docs/recovery_full_audit

declare -a TARGETS=(
  "phase65_layout|8081|mbhq_phase65_layout"
  "phase65_wiring|8082|mbhq_phase65_wiring"
  "operator_guidance|8083|mbhq_operator_guidance"
)

for item in "${TARGETS[@]}"; do
  NAME="${item%%|*}"
  REST="${item#*|}"
  PORT="${REST%%|*}"
  PROJECT="${REST##*|}"
  WT_PATH="$WT_BASE/$NAME"

  if [ ! -d "$WT_PATH" ]; then
    echo "MISSING_WORKTREE=$WT_PATH"
    exit 1
  fi

  cat > "$WT_PATH/docker-compose.phase457.override.yml" <<OVERRIDE
services:
  dashboard:
    ports:
      - "${PORT}:3000"
OVERRIDE

  (
    cd "$WT_PATH"
    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f docker-compose.yml \
      -f docker-compose.phase457.override.yml \
      up --build -d dashboard
  ) > "docs/recovery_full_audit/${NAME}_launch_port_${PORT}.txt" 2>&1 || true
done

{
  echo "PHASE 457 - RECOVERY VISUAL COMPARE LAUNCH"
  echo "=========================================="
  echo
  echo "PURPOSE"
  echo "Launch each recovery candidate on a dedicated local port for side-by-side manual comparison."
  echo
  for item in "${TARGETS[@]}"; do
    NAME="${item%%|*}"
    REST="${item#*|}"
    PORT="${REST%%|*}"
    PROJECT="${REST##*|}"
    WT_PATH="$WT_BASE/$NAME"
    echo "NAME=$NAME"
    echo "WORKTREE=$WT_PATH"
    echo "PROJECT=$PROJECT"
    echo "URL=http://localhost:${PORT}"
    echo "LOG=docs/recovery_full_audit/${NAME}_launch_port_${PORT}.txt"
    echo
  done
  echo "STOP CONDITION"
  echo "Do not mutate the main branch until one candidate is visually confirmed as the desired checkpoint."
} > "$OUT"

open "http://localhost:8081" || true
open "http://localhost:8082" || true
open "http://localhost:8083" || true

echo "WROTE=$OUT"
sed -n '1,220p' "$OUT"
