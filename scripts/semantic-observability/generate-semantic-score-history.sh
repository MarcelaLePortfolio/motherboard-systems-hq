
#!/bin/bash

set -euo pipefail

OUTPUT_FILE="runtime/semantic-preview-planning/semantic-score-history.md"

CURRENT_TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

SCORE_OUTPUT=$(./scripts/semantic-observability/generate-semantic-consistency-score.sh 2>&1)

CONSISTENCY_SCORE=$(echo "$SCORE_OUTPUT" | grep "Consistency score:" | awk '{print $3}')

mkdir -p runtime/semantic-preview-planning

if [[ ! -f "$OUTPUT_FILE" ]]; then

  echo "# Semantic Score History" > "$OUTPUT_FILE"

  echo "" >> "$OUTPUT_FILE"

fi

echo "- $CURRENT_TIMESTAMP :: consistency score = $CONSISTENCY_SCORE" >> "$OUTPUT_FILE"

echo "Semantic score history updated:"

echo "$OUTPUT_FILE"

tail -n 5 "$OUTPUT_FILE"

