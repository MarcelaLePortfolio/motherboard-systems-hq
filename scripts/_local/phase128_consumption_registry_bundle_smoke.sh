#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

REGISTRY_DIR="src/cognition/transport/consumptionRegistry"
BUNDLE_FILE="$REGISTRY_DIR/consumption_registry_enforcement_bundle.ts"
INDEX_FILE="$REGISTRY_DIR/index.ts"

[[ -f "$BUNDLE_FILE" ]] || { echo "Missing bundle module: $BUNDLE_FILE"; exit 1; }

grep -q 'export function createConsumptionRegistryEnforcementBundle' "$BUNDLE_FILE" || {
  echo "Expected createConsumptionRegistryEnforcementBundle export missing"
  exit 1
}

grep -q 'createConsumptionRegistryEnforcementFixtureSet' "$BUNDLE_FILE" || {
  echo "Expected fixture integration missing"
  exit 1
}

grep -q 'createConsumptionRegistryEnforcementSnapshot' "$BUNDLE_FILE" || {
  echo "Expected snapshot integration missing"
  exit 1
}

[[ -f "$INDEX_FILE" ]] || { echo "Missing index barrel: $INDEX_FILE"; exit 1; }

grep -q 'consumption_registry_enforcement_bundle' "$INDEX_FILE" || {
  echo "Index barrel missing consumption_registry_enforcement_bundle export"
  exit 1
}

echo "phase128 bundle smoke: PASS"
