#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

REGISTRY_DIR="src/cognition/transport/consumptionRegistry"
READONLY_VIEW_FILE="$REGISTRY_DIR/consumption_registry_enforcement_readonly_view.ts"
INDEX_FILE="$REGISTRY_DIR/index.ts"

[[ -f "$READONLY_VIEW_FILE" ]] || { echo "Missing readonly view module: $READONLY_VIEW_FILE"; exit 1; }

grep -q 'export function createConsumptionRegistryEnforcementReadonlyView' "$READONLY_VIEW_FILE" || {
  echo "Expected createConsumptionRegistryEnforcementReadonlyView export missing"
  exit 1
}

grep -q 'runConsumptionRegistryEnforcementRuntimeGuard' "$READONLY_VIEW_FILE" || {
  echo "Expected runtime guard integration missing"
  exit 1
}

grep -q 'ownershipKeyCount=' "$READONLY_VIEW_FILE" || {
  echo "Expected ownershipKeyCount readonly output missing"
  exit 1
}

grep -q 'missingConsumerCount=' "$READONLY_VIEW_FILE" || {
  echo "Expected missingConsumerCount readonly output missing"
  exit 1
}

grep -q 'duplicateOwnershipCount=' "$READONLY_VIEW_FILE" || {
  echo "Expected duplicateOwnershipCount readonly output missing"
  exit 1
}

[[ -f "$INDEX_FILE" ]] || { echo "Missing index barrel: $INDEX_FILE"; exit 1; }

grep -q 'consumption_registry_enforcement_readonly_view' "$INDEX_FILE" || {
  echo "Index barrel missing consumption_registry_enforcement_readonly_view export"
  exit 1
}

echo "phase128 readonly view smoke: PASS"
