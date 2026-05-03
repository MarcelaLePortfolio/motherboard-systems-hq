#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

REGISTRY_DIR="src/cognition/transport/consumptionRegistry"
RUNTIME_GUARD_FILE="$REGISTRY_DIR/consumption_registry_enforcement_runtime_guard.ts"
INDEX_FILE="$REGISTRY_DIR/index.ts"

[[ -f "$RUNTIME_GUARD_FILE" ]] || { echo "Missing runtime guard module: $RUNTIME_GUARD_FILE"; exit 1; }

grep -q 'export function runConsumptionRegistryEnforcementRuntimeGuard' "$RUNTIME_GUARD_FILE" || {
  echo "Expected runConsumptionRegistryEnforcementRuntimeGuard export missing"
  exit 1
}

grep -q 'createConsumptionRegistryEnforcementBundle' "$RUNTIME_GUARD_FILE" || {
  echo "Expected bundle integration missing"
  exit 1
}

grep -q 'runtime guard passed' "$RUNTIME_GUARD_FILE" || {
  echo "Expected pass message missing"
  exit 1
}

grep -q 'runtime guard failed' "$RUNTIME_GUARD_FILE" || {
  echo "Expected fail message missing"
  exit 1
}

[[ -f "$INDEX_FILE" ]] || { echo "Missing index barrel: $INDEX_FILE"; exit 1; }

grep -q 'consumption_registry_enforcement_runtime_guard' "$INDEX_FILE" || {
  echo "Index barrel missing consumption_registry_enforcement_runtime_guard export"
  exit 1
}

echo "phase128 runtime guard smoke: PASS"
