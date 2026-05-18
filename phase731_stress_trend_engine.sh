
#!/bin/bash

set -euo pipefail

TARGET="scripts/semantic-observability/generate-semantic-trend-analysis.sh"

HISTORY_FILE="runtime/semantic-preview-planning/semantic-score-history.md"

BACKUP_FILE="$(mktemp)"

cp "$HISTORY_FILE" "$BACKUP_FILE"

restore_history() {

  cp "$BACKUP_FILE" "$HISTORY_FILE"

  rm -f "$BACKUP_FILE"

}

trap restore_history EXIT

run_case() {

  local name="$1"

  shift

  local scores=("$@")

  echo

  echo "=============================="

  echo "CASE: $name"

  echo "SCORES: ${scores[*]}"

  echo "=============================="

  : > "$HISTORY_FILE"

  for score in "${scores[@]}"; do

    echo "- consistency score = $score" >> "$HISTORY_FILE"

  done

  bash "$TARGET"

}

echo "== PHASE 731 CONTROLLED TREND STRESS HARNESS =="

run_case "stable flat" 160 160 160

run_case "gradual upward drift" 150 155 160

run_case "gradual downward drift" 160 155 150

run_case "oscillation reversal" 160 150 160

run_case "variance spike upward" 100 160 220

run_case "variance spike downward" 220 160 100

echo

echo "== HISTORY RESTORED BY EXIT TRAP =="

