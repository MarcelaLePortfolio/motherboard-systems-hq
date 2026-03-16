#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 69 TELEMETRY REPLAY RUNNER"
echo "--------------------------------"

REPLAY_DIR="scripts/_local/fixtures/replay"
VALIDATOR="scripts/_local/phase68_event_schema_validator.ts"

if [ ! -d "$REPLAY_DIR" ]; then
  echo "FAIL: replay directory missing"
  exit 1
fi

if [ ! -f "$VALIDATOR" ]; then
  echo "FAIL: validator missing"
  exit 1
fi

FILES=$(ls "$REPLAY_DIR"/task_events_replay_*.json 2>/dev/null || true)

if [ -z "$FILES" ]; then
  echo "WARN: no replay files found"
  exit 0
fi

run_validator() {
  local file="$1"

  echo
  echo "Replaying:"
  echo "$file"

  if command -v tsx >/dev/null 2>&1; then
    tsx "$VALIDATOR" "$(cat "$file")"
  elif command -v pnpm >/dev/null 2>&1; then
    pnpm exec tsx "$VALIDATOR" "$(cat "$file")"
  elif command -v npx >/dev/null 2>&1; then
    npx tsx "$VALIDATOR" "$(cat "$file")"
  else
    echo "FAIL: tsx runtime not available"
    exit 1
  fi
}

for f in $FILES; do
  run_validator "$f"
done

echo
echo "Phase 69 replay validation COMPLETE"
