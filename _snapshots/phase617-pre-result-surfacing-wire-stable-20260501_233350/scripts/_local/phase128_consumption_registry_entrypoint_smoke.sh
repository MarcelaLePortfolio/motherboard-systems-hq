#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

REGISTRY_DIR="src/cognition/transport/consumptionRegistry"
ENTRYPOINT_FILE="$REGISTRY_DIR/consumption_registry_enforcement_entrypoint.ts"
INDEX_FILE="$REGISTRY_DIR/index.ts"

[[ -f "$ENTRYPOINT_FILE" ]] || { echo "Missing entrypoint module: $ENTRYPOINT_FILE"; exit 1; }

grep -q 'export function runConsumptionRegistryEnforcementEntrypoint' "$ENTRYPOINT_FILE" || {
  echo "Expected runConsumptionRegistryEnforcementEntrypoint export missing"
  exit 1
}

grep -q 'createConsumptionRegistryEnforcementReadonlyView' "$ENTRYPOINT_FILE" || {
  echo "Expected readonly view integration missing"
  exit 1
}

grep -q 'ok: view.ok' "$ENTRYPOINT_FILE" || {
  echo "Expected entrypoint ok passthrough missing"
  exit 1
}

[[ -f "$INDEX_FILE" ]] || { echo "Missing index barrel: $INDEX_FILE"; exit 1; }

grep -q 'consumption_registry_enforcement_entrypoint' "$INDEX_FILE" || {
  echo "Index barrel missing consumption_registry_enforcement_entrypoint export"
  exit 1
}

echo "phase128 entrypoint smoke: PASS"
