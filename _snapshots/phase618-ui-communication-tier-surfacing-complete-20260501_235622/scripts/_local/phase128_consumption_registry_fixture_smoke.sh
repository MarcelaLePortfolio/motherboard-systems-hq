#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

REGISTRY_DIR="src/cognition/transport/consumptionRegistry"
FIXTURE_FILE="$REGISTRY_DIR/consumption_registry_enforcement_fixture.ts"
INDEX_FILE="$REGISTRY_DIR/index.ts"

[[ -f "$FIXTURE_FILE" ]] || { echo "Missing fixture module: $FIXTURE_FILE"; exit 1; }

grep -q 'export function createConsumptionRegistryEnforcementFixtureSet' "$FIXTURE_FILE" || {
  echo "Expected createConsumptionRegistryEnforcementFixtureSet export missing"
  exit 1
}

grep -q 'export function createConsumptionRegistryEnforcementFixtureProof' "$FIXTURE_FILE" || {
  echo "Expected createConsumptionRegistryEnforcementFixtureProof export missing"
  exit 1
}

grep -q 'fixture-missing-consumer' "$FIXTURE_FILE" || {
  echo "Expected missing consumer fixture missing"
  exit 1
}

grep -q 'runtime-registry-owner-a' "$FIXTURE_FILE" || {
  echo "Expected duplicate owner fixture missing"
  exit 1
}

[[ -f "$INDEX_FILE" ]] || { echo "Missing index barrel: $INDEX_FILE"; exit 1; }

grep -q 'consumption_registry_enforcement_fixture' "$INDEX_FILE" || {
  echo "Index barrel missing consumption_registry_enforcement_fixture export"
  exit 1
}

echo "phase128 fixture smoke: PASS"
