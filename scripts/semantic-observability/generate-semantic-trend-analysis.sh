
#!/bin/bash

set -euo pipefail

DEBUG=0

WINDOW_SIZE=3

if [[ "${1:-}" == "--debug" ]]; then

  DEBUG=1

fi

HISTORY_FILE="runtime/semantic-preview-planning/semantic-score-history.md"

echo "Semantic Trend Report (Confidence Model)"

echo "----------------------------------------"

if [[ ! -f "$HISTORY_FILE" ]]; then

  echo "ERROR: No history file found"

  exit 1

fi

RAW_LINES=$(grep "consistency score" "$HISTORY_FILE" || true)

SCORES=($(echo "$RAW_LINES" | awk -F= '{print $2}' | tr -d ' '))

# filter numeric only

FILTERED=()

for s in "${SCORES[@]}"; do

  if [[ "$s" =~ ^[0-9]+$ ]]; then

    FILTERED+=("$s")

  fi

done

SCORES=("${FILTERED[@]}")

COUNT=${#SCORES[@]}

if [[ "$COUNT" -lt "$WINDOW_SIZE" ]]; then

  echo "ERROR: Not enough data for analysis (need $WINDOW_SIZE, found $COUNT)"

  exit 1

fi

WINDOW=("${SCORES[@]:$((COUNT - WINDOW_SIZE))}")

FIRST=${WINDOW[0]}

MIDDLE=${WINDOW[1]}

LAST=${WINDOW[2]}

# Macro slope

SLOPE=$((LAST - FIRST))

# Micro movement

MICRO_1=$((MIDDLE - FIRST))

MICRO_2=$((LAST - MIDDLE))

# Variance

SUM=0

for s in "${WINDOW[@]}"; do

  SUM=$((SUM + s))

done

AVG=$((SUM / WINDOW_SIZE))

VAR_SUM=0

for s in "${WINDOW[@]}"; do

  DIFF=$((s - AVG))

  VAR_SUM=$((VAR_SUM + DIFF * DIFF))

done

VAR=$((VAR_SUM / WINDOW_SIZE))

# -------------------------

# TREND CLASSIFICATION

# -------------------------

if [[ "$SLOPE" -gt 0 ]]; then

  TREND="Improving"

elif [[ "$SLOPE" -lt 0 ]]; then

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

if [[ "$MICRO_1" -gt 0 && "$MICRO_2" -gt 0 ]]; then

  MICRO_SIGNAL="Upward"

elif [[ "$MICRO_1" -lt 0 && "$MICRO_2" -lt 0 ]]; then

  MICRO_SIGNAL="Downward"

elif [[ "$MICRO_1" -ne "$MICRO_2" ]]; then

  MICRO_SIGNAL="Oscillation"

else

  MICRO_SIGNAL="Flat"

fi

# -------------------------

# CONFIDENCE MODEL (NEW)

# -------------------------

CONFIDENCE=0

# 1. data size contribution

CONFIDENCE=$((CONFIDENCE + COUNT * 10))

# 2. stability contribution

if [[ "$VAR" -eq 0 ]]; then

  CONFIDENCE=$((CONFIDENCE + 40))

elif [[ "$VAR" -lt 10 ]]; then

  CONFIDENCE=$((CONFIDENCE + 25))

elif [[ "$VAR" -lt 50 ]]; then

  CONFIDENCE=$((CONFIDENCE + 10))

fi

# 3. signal agreement

if [[ "$TREND" == "Improving" && "$MICRO_SIGNAL" == "Upward" ]]; then

  CONFIDENCE=$((CONFIDENCE + 30))

elif [[ "$TREND" == "Degrading" && "$MICRO_SIGNAL" == "Downward" ]]; then

  CONFIDENCE=$((CONFIDENCE + 30))

elif [[ "$TREND" == "Stable" && "$MICRO_SIGNAL" == "Flat" ]]; then

  CONFIDENCE=$((CONFIDENCE + 30))

else

  CONFIDENCE=$((CONFIDENCE + 5))

fi

# cap confidence

if [[ "$CONFIDENCE" -gt 100 ]]; then

  CONFIDENCE=100

fi

echo ""

echo "Window: ${WINDOW[@]}"

echo "Slope: $SLOPE"

echo "Micro: $MICRO_1 → $MICRO_2 ($MICRO_SIGNAL)"

echo "Variance: $VAR"

echo ""

echo "Trend: $TREND"

echo "Volatility: $VOLATILITY"

echo "Confidence: ${CONFIDENCE}/100"

echo ""

# FINAL INTERPRETATION

if [[ "$CONFIDENCE" -ge 80 ]]; then

  RELIABILITY="High"

elif [[ "$CONFIDENCE" -ge 50 ]]; then

  RELIABILITY="Medium"

else

  RELIABILITY="Low"

fi

echo "Reliability: $RELIABILITY"

if [[ "$TREND" == "Stable" && "$RELIABILITY" == "High" ]]; then

  echo "Direction: Strong stable system"

elif [[ "$TREND" == "Improving" && "$RELIABILITY" == "High" ]]; then

  echo "Direction: Confident upward drift"

elif [[ "$TREND" == "Degrading" && "$RELIABILITY" == "High" ]]; then

  echo "Direction: Confident downward drift"

else

  echo "Direction: Weak or uncertain signal"

fi

