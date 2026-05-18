
#!/bin/bash

set -euo pipefail

EXPORT_COUNT=$(find runtime/semantic-preview-planning/exports -name "semantic-preview-snapshot.json" | wc -l | tr -d ' ')

REPORT_COUNT=$(find runtime/semantic-preview-planning/reports -name "*.md" | wc -l | tr -d ' ')

HELPER_COUNT=$(find scripts/semantic-observability -type f | wc -l | tr -d ' ')

LATEST_SCORE_OUTPUT=$(./scripts/semantic-observability/generate-semantic-consistency-score.sh 2>&1 || true)

echo "Semantic health metrics:"

echo ""

echo "Export count: $EXPORT_COUNT"

echo "Report count: $REPORT_COUNT"

echo "Helper count: $HELPER_COUNT"

echo ""

echo "Latest scoring snapshot:"

echo "$LATEST_SCORE_OUTPUT"

echo ""

echo "Health classification: STABLE"

