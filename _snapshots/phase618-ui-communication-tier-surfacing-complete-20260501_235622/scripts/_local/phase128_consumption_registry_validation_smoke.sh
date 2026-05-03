#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

REGISTRY_DIR="src/cognition/transport/consumptionRegistry"
VALIDATION_FILE="$REGISTRY_DIR/consumption_registry_enforcement_validation.ts"
INDEX_FILE="$REGISTRY_DIR/index.ts"

[[ -f "$VALIDATION_FILE" ]] || { echo "Missing validation module: $VALIDATION_FILE"; exit 1; }
grep -q 'export function validateConsumptionRegistryEnforcement' "$VALIDATION_FILE" || {
  echo "Expected validateConsumptionRegistryEnforcement export missing"
  exit 1
}
grep -q 'function renderIssue' "$VALIDATION_FILE" || {
  echo "Expected deterministic issue renderer missing"
  exit 1
}

[[ -f "$INDEX_FILE" ]] || { echo "Missing index barrel: $INDEX_FILE"; exit 1; }
grep -q 'consumption_registry_enforcement_validation' "$INDEX_FILE" || {
  echo "Index barrel missing consumption_registry_enforcement_validation export"
  exit 1
}

echo "phase128 validation smoke: PASS"
