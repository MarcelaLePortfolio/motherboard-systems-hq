#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

REGISTRY_DIR="src/cognition/transport/consumptionRegistry"
REPORT_FILE="$REGISTRY_DIR/consumption_registry_enforcement_report.ts"
INDEX_FILE="$REGISTRY_DIR/index.ts"

[[ -f "$REPORT_FILE" ]] || { echo "Missing report module: $REPORT_FILE"; exit 1; }

grep -q 'export function createConsumptionRegistryEnforcementReport' "$REPORT_FILE" || {
  echo "Expected createConsumptionRegistryEnforcementReport export missing"
  exit 1
}

grep -q 'function sortLines' "$REPORT_FILE" || {
  echo "Expected deterministic line sorter missing"
  exit 1
}

[[ -f "$INDEX_FILE" ]] || { echo "Missing index barrel: $INDEX_FILE"; exit 1; }

grep -q 'consumption_registry_enforcement_report' "$INDEX_FILE" || {
  echo "Index barrel missing consumption_registry_enforcement_report export"
  exit 1
}

echo "phase128 report smoke: PASS"
