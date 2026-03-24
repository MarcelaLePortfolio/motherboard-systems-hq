#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

REGISTRY_DIR="src/cognition/transport/consumptionRegistry"
SNAPSHOT_FILE="$REGISTRY_DIR/consumption_registry_enforcement_snapshot.ts"
INDEX_FILE="$REGISTRY_DIR/index.ts"

[[ -f "$SNAPSHOT_FILE" ]] || { echo "Missing snapshot module: $SNAPSHOT_FILE"; exit 1; }

grep -q 'export function createConsumptionRegistryEnforcementSnapshot' "$SNAPSHOT_FILE" || {
  echo "Expected createConsumptionRegistryEnforcementSnapshot export missing"
  exit 1
}

grep -q 'generatedAt = "deterministic-proof"' "$SNAPSHOT_FILE" || {
  echo "Expected deterministic generatedAt default missing"
  exit 1
}

grep -q 'runConsumptionRegistryEnforcementProof' "$SNAPSHOT_FILE" || {
  echo "Expected proof integration missing"
  exit 1
}

[[ -f "$INDEX_FILE" ]] || { echo "Missing index barrel: $INDEX_FILE"; exit 1; }

grep -q 'consumption_registry_enforcement_snapshot' "$INDEX_FILE" || {
  echo "Index barrel missing consumption_registry_enforcement_snapshot export"
  exit 1
}

echo "phase128 snapshot smoke: PASS"
