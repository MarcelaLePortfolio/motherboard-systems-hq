
#!/bin/bash

set -euo pipefail

OUTPUT_FILE="runtime/semantic-preview-planning/preview-overlay-mock.md"

LATEST_SCORE=$(./scripts/semantic-observability/generate-semantic-consistency-score.sh | grep "Consistency score:" | awk '{print $3}')

LATEST_DRIFT=$(./scripts/semantic-observability/detect-semantic-export-drift.sh | grep "Drift status:" | sed 's/Drift status: //')

LATEST_ANOMALY=$(./scripts/semantic-observability/generate-semantic-anomaly-scan.sh | grep "Semantic anomaly classification:" | sed 's/Semantic anomaly classification: //')

cat > "$OUTPUT_FILE" << OVERLAY

# Preview Overlay Mock

## Hypothetical Overlay Signals

- semantic consistency score: $LATEST_SCORE

- drift inspection status: $LATEST_DRIFT

- anomaly inspection status: $LATEST_ANOMALY

## Overlay Classification

DEVELOPER-ONLY MOCK — NON-RUNTIME — NON-AUTHORITATIVE

## Preserved Boundaries

- renderer authority preserved

- execution authority preserved

- orchestration authority preserved

- persistence authority preserved

## Overlay Containment

- markdown-only

- observational only

- additive only

- rollback-safe

- renderer-independent

## Explicit Safety Notice

This overlay mock does not integrate with Preview, renderer systems, runtime execution, orchestration, SSE infrastructure, persistence, or layout systems.

OVERLAY

echo "Preview overlay mock generated:"

echo "$OUTPUT_FILE"

cat "$OUTPUT_FILE"

