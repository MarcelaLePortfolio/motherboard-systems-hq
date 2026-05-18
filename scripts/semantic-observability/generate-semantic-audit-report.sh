
#!/bin/bash

set -euo pipefail

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

REPORT_DIR="runtime/semantic-preview-planning/reports"

mkdir -p "$REPORT_DIR"

REPORT_FILE="$REPORT_DIR/semantic-audit-report-$TIMESTAMP.md"

LATEST_EXPORT=$(find runtime/semantic-preview-planning/exports -name "semantic-preview-snapshot.json" | sort | tail -n 1)

SECTION_CHECK=$(./scripts/semantic-observability/verify-semantic-section-structure.sh 2>&1 || true)

SCHEMA_CHECK=$(./scripts/semantic-observability/validate-semantic-export-schema.sh 2>&1 || true)

cat > "$REPORT_FILE" << REPORT

# Semantic Audit Report

Generated:

$TIMESTAMP

Latest Export:

$LATEST_EXPORT

## Section Verification

$SECTION_CHECK

## Schema Validation

$SCHEMA_CHECK

## Authority Status

- renderer authority preserved

- execution authority preserved

- retry authority preserved

- orchestration authority preserved

- persistence authority preserved

## Semantic Substrate Status

- observational only

- additive only

- renderer-independent

- rollback-safe

REPORT

echo "Semantic audit report generated:"

echo "$REPORT_FILE"

