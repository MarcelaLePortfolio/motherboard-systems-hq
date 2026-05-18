
#!/bin/bash

set -euo pipefail

OUTPUT_FILE="runtime/semantic-preview-planning/dashboard-snapshot.md"

EXPORT_COUNT=$(find runtime/semantic-preview-planning/exports -name "semantic-preview-snapshot.json" | wc -l | tr -d ' ')

REPORT_COUNT=$(find runtime/semantic-preview-planning/reports -name "*.md" | wc -l | tr -d ' ')

HELPER_COUNT=$(find scripts/semantic-observability -type f | wc -l | tr -d ' ')

LATEST_SCORE=$(./scripts/semantic-observability/generate-semantic-consistency-score.sh | grep "Consistency score:" | awk '{print $3}')

LATEST_DRIFT=$(./scripts/semantic-observability/detect-semantic-export-drift.sh | grep "Drift status:" | sed 's/Drift status: //')

LATEST_ANOMALY=$(./scripts/semantic-observability/generate-semantic-anomaly-scan.sh | grep "Semantic anomaly classification:" | sed 's/Semantic anomaly classification: //')

cat > "$OUTPUT_FILE" << DASHBOARD

# Semantic Dashboard Snapshot

## Semantic Health

- consistency score: $LATEST_SCORE

- drift status: $LATEST_DRIFT

- anomaly classification: $LATEST_ANOMALY

## Observability Inventory

- exports: $EXPORT_COUNT

- reports: $REPORT_COUNT

- helpers: $HELPER_COUNT

## Authority Preservation

- renderer authority preserved

- execution authority preserved

- orchestration authority preserved

- persistence authority preserved

## Containment Status

- developer-only

- observational only

- additive only

- rollback-safe

DASHBOARD

echo "Semantic dashboard snapshot generated:"

echo "$OUTPUT_FILE"

cat "$OUTPUT_FILE"

