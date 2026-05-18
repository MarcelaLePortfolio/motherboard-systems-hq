
#!/bin/bash

set -euo pipefail

TARGET="scripts/semantic-observability/generate-semantic-trend-analysis.sh"

HISTORY_FILE="runtime/semantic-preview-planning/semantic-score-history.md"

BACKUP_FILE="$(mktemp)"

FAILURES=0

cp "$HISTORY_FILE" "$BACKUP_FILE"

restore_history() {

  cp "$BACKUP_FILE" "$HISTORY_FILE"

  rm -f "$BACKUP_FILE"

}

trap restore_history EXIT

assert_case() {

  local name="$1"

  local expected_trend="$2"

  local expected_volatility="$3"

  local expected_confidence="$4"

  local expected_reliability="$5"

  shift 5

  local scores=("$@")

  local output

  : > "$HISTORY_FILE"

  for score in "${scores[@]}"; do

    echo "- consistency score = $score" >> "$HISTORY_FILE"

  done

  output="$(bash "$TARGET")"

  echo

  echo "CASE: $name"

  if ! grep -q "Trend: $expected_trend" <<< "$output"; then

    echo "FAIL trend expected=$expected_trend"

    FAILURES=$((FAILURES + 1))

  fi

  if ! grep -q "Volatility: $expected_volatility" <<< "$output"; then

    echo "FAIL volatility expected=$expected_volatility"

    FAILURES=$((FAILURES + 1))

  fi

  if ! grep -q "Confidence: $expected_confidence/100" <<< "$output"; then

    echo "FAIL confidence expected=$expected_confidence/100"

    FAILURES=$((FAILURES + 1))

  fi

  if ! grep -q "Reliability: $expected_reliability" <<< "$output"; then

    echo "FAIL reliability expected=$expected_reliability"

    FAILURES=$((FAILURES + 1))

  fi

  if [[ "$FAILURES" -eq 0 ]]; then

    echo "PASS"

  else

    echo "$output"

  fi

}

echo "== PHASE 731 TREND ENGINE ASSERTIONS =="

assert_case "stable flat" "Stable" "Low" "100" "High" 160 160 160

assert_case "gradual upward drift" "Improving" "Medium" "70" "Medium" 150 155 160

assert_case "gradual downward drift" "Degrading" "Medium" "70" "Medium" 160 155 150

assert_case "oscillation reversal" "Stable" "Medium" "45" "Low" 160 150 160

assert_case "variance spike upward" "Improving" "Extreme" "25" "Low" 100 160 220

assert_case "variance spike downward" "Degrading" "Extreme" "25" "Low" 220 160 100

echo

if [[ "$FAILURES" -ne 0 ]]; then

  echo "ASSERTION RESULT: FAIL ($FAILURES failure(s))"

  exit 1

fi

echo "ASSERTION RESULT: PASS"

