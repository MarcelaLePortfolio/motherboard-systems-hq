
#!/bin/bash

set -euo pipefail

HISTORY_FILE="runtime/semantic-preview-planning/semantic-score-history.md"

echo "Semantic Trend Report"

echo "---------------------"

if [[ ! -f "$HISTORY_FILE" ]]; then

  echo "ERROR: No history file found at $HISTORY_FILE"

  exit 1

fi

# Extract numeric scores from history file

SCORES=($(grep "consistency score =" "$HISTORY_FILE" | awk -F= '{print $2}' | tr -d ' '))

COUNT=${#SCORES[@]}

if [[ "$COUNT" -lt 2 ]]; then

  echo "Not enough data for trend analysis."

  echo "Entries found: $COUNT"

  exit 0

fi

LATEST=${SCORES[$((COUNT-1))]}

PREVIOUS=${SCORES[$((COUNT-2))]}

DELTA=$((LATEST - PREVIOUS))

# Compute simple average

SUM=0

for s in "${SCORES[@]}"; do

  SUM=$((SUM + s))

done

AVG=$((SUM / COUNT))

# Simple variance approximation (integer-based)

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

# Trend classification

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

else

  echo "Direction: Mixed / unstable pattern"

fi

