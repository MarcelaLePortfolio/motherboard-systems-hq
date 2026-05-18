
#!/bin/bash

set -euo pipefail

DEBUG=0

if [[ "${1:-}" == "--debug" ]]; then

  DEBUG=1

fi

HISTORY_FILE="runtime/semantic-preview-planning/semantic-score-history.md"

echo "Semantic Trend Report"

echo "---------------------"

if [[ ! -f "$HISTORY_FILE" ]]; then

  echo "ERROR: No history file found"

  exit 1

fi

RAW_LINES=$(grep "consistency score" "$HISTORY_FILE" || true)

SCORES=($(echo "$RAW_LINES" | awk -F= '{print $2}' | tr -d ' '))

if [[ "$DEBUG" -eq 1 ]]; then

  echo "[DEBUG] Raw lines:"

  echo "$RAW_LINES"

  echo "[DEBUG] Scores:"

  echo "${SCORES[@]}"

fi

COUNT=${#SCORES[@]}

if [[ "$COUNT" -lt 2 ]]; then

  echo "ERROR: Not enough valid score entries (found $COUNT)"

  exit 1

fi

FILTERED=()

for s in "${SCORES[@]}"; do

  if [[ "$s" =~ ^[0-9]+$ ]]; then

    FILTERED+=("$s")

  fi

done

SCORES=("${FILTERED[@]}")

COUNT=${#SCORES[@]}

LATEST=${SCORES[$((COUNT-1))]}

PREVIOUS=${SCORES[$((COUNT-2))]}

DELTA=$((LATEST - PREVIOUS))

SUM=0

for s in "${SCORES[@]}"; do

  SUM=$((SUM + s))

done

AVG=$((SUM / COUNT))

VAR_SUM=0

for s in "${SCORES[@]}"; do

  DIFF=$((s - AVG))

  VAR_SUM=$((VAR_SUM + DIFF * DIFF))

done

VAR=$((VAR_SUM / COUNT))

echo ""

echo "Latest Score: $LATEST"

echo "Previous Score: $PREVIOUS"

echo "Delta: $DELTA"

echo "Average: $AVG"

echo "Variance: $VAR"

echo ""

if [[ "$DELTA" -gt 0 ]]; then

  TREND="Improving"

elif [[ "$DELTA" -lt 0 ]]; then

  TREND="Degrading"

else

  TREND="Stable"

fi

if [[ "$VAR" -gt 50 ]]; then

  VOLATILITY="High"

elif [[ "$VAR" -gt 10 ]]; then

  VOLATILITY="Medium"

else

  VOLATILITY="Low"

fi

echo "Trend: $TREND"

echo "Volatility: $VOLATILITY"

if [[ "$TREND" == "Improving" && "$VOLATILITY" == "Low" ]]; then

  echo "Direction: Stable upward drift"

elif [[ "$TREND" == "Degrading" && "$VOLATILITY" == "Low" ]]; then

  echo "Direction: Stable downward drift"

elif [[ "$TREND" == "Stable" && "$VOLATILITY" == "Low" ]]; then

  echo "Direction: Flat stable plateau"

else

  echo "Direction: Mixed / unstable pattern"

fi

