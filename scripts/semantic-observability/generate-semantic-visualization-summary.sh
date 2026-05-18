
#!/bin/bash

set -euo pipefail

OUTPUT_FILE="runtime/semantic-preview-planning/semantic-visualization-summary.md"

LATEST_HEALTH=$(./scripts/semantic-observability/generate-semantic-health-metrics.sh | tail -n 1)

LATEST_DRIFT=$(./scripts/semantic-observability/detect-semantic-export-drift.sh | grep "Drift status:" | sed 's/Drift status: //')

LATEST_ANOMALY=$(./scripts/semantic-observability/generate-semantic-anomaly-scan.sh | grep "Semantic anomaly classification:" | sed 's/Semantic anomaly classification: //')

LATEST_SCORE=$(./scripts/semantic-observability/generate-semantic-consistency-score.sh | grep "Consistency score:" | awk '{print $3}')

cat > "$OUTPUT_FILE" << SUMMARY

# Semantic Visualization Summary

## Semantic Stability

- health classification: $LATEST_HEALTH

- drift inspection: $LATEST_DRIFT

- anomaly inspection: $LATEST_ANOMALY

- consistency score: $LATEST_SCORE

## Visualization Containment

- developer-only

- markdown-only

- observational only

- additive only

- rollback-safe

## Preserved Authorities

- renderer authority preserved

- execution authority preserved

- orchestration authority preserved

- persistence authority preserved

## Corridor Classification

PREVIEW-ADJACENT PLANNING ONLY — NO LIVE RUNTIME INTEGRATION

SUMMARY

echo "Semantic visualization summary generated:"

echo "$OUTPUT_FILE"

cat "$OUTPUT_FILE"

