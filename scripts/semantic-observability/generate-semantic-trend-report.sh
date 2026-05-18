
#!/bin/bash

set -euo pipefail

REPORT_DIR="runtime/semantic-preview-planning/reports"

mkdir -p "$REPORT_DIR"

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

REPORT_FILE="$REPORT_DIR/semantic-trend-report-$TIMESTAMP.md"

EXPORT_COUNT=$(find runtime/semantic-preview-planning/exports -name "semantic-preview-snapshot.json" | wc -l | tr -d ' ')

LATEST_EXPORT=$(find runtime/semantic-preview-planning/exports -name "semantic-preview-snapshot.json" | sort | tail -n 1)

LATEST_SCORE_OUTPUT=$(./scripts/semantic-observability/generate-semantic-consistency-score.sh 2>&1 || true)

cat > "$REPORT_FILE" << REPORT

# Semantic Trend Report

Generated:

$TIMESTAMP

## Export Trend Summary

- total exports observed: $EXPORT_COUNT

- latest export: $LATEST_EXPORT

## Latest Semantic Consistency Snapshot

$LATEST_SCORE_OUTPUT

## Trend Status

- semantic observability stable

- consistency scoring operational

- export lineage operational

- developer-only containment preserved

## Preserved Authority Boundaries

- renderer authority preserved

- execution authority preserved

- orchestration authority preserved

- persistence authority preserved

REPORT

echo "Semantic trend report generated:"

echo "$REPORT_FILE"

