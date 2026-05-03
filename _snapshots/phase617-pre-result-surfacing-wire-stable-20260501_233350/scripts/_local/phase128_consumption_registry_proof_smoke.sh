#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

REGISTRY_DIR="src/cognition/transport/consumptionRegistry"
PROOF_FILE="$REGISTRY_DIR/consumption_registry_enforcement_proof.ts"
INDEX_FILE="$REGISTRY_DIR/index.ts"

[[ -f "$PROOF_FILE" ]] || { echo "Missing proof module: $PROOF_FILE"; exit 1; }

grep -q 'export function runConsumptionRegistryEnforcementProof' "$PROOF_FILE" || {
  echo "Expected runConsumptionRegistryEnforcementProof export missing"
  exit 1
}

grep -q 'proof.invalidReport.summary.duplicateOwnershipCount > 0' "$PROOF_FILE" || {
  echo "Expected duplicate ownership proof assertion missing"
  exit 1
}

grep -q 'proof.invalidReport.summary.missingConsumerCount > 0' "$PROOF_FILE" || {
  echo "Expected missing consumer proof assertion missing"
  exit 1
}

[[ -f "$INDEX_FILE" ]] || { echo "Missing index barrel: $INDEX_FILE"; exit 1; }

grep -q 'consumption_registry_enforcement_proof' "$INDEX_FILE" || {
  echo "Index barrel missing consumption_registry_enforcement_proof export"
  exit 1
}

echo "phase128 proof smoke: PASS"
