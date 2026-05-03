#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

REGISTRY_DIR="$(find src -type f \( -iname '*consumption*registry*.ts' -o -iname '*consumption*registry*.js' \) | grep -viE '(test|spec)' | xargs -I{} dirname {} | sort | uniq | head -n 1)"
if [[ -z "${REGISTRY_DIR:-}" ]]; then
  REGISTRY_DIR="src/cognition/transport/consumption"
fi

TARGET="$REGISTRY_DIR/consumption_registry_enforcement.ts"
INDEX_FILE="$REGISTRY_DIR/index.ts"

[[ -f "$TARGET" ]] || { echo "Missing enforcement module: $TARGET"; exit 1; }
grep -q 'export function enforceConsumptionRegistryOwnership' "$TARGET" || {
  echo "Expected enforceConsumptionRegistryOwnership export missing"
  exit 1
}

[[ -f "$INDEX_FILE" ]] || { echo "Missing index barrel: $INDEX_FILE"; exit 1; }
grep -q 'consumption_registry_enforcement' "$INDEX_FILE" || {
  echo "Index barrel missing consumption_registry_enforcement export"
  exit 1
}

echo "phase128 enforcement smoke: PASS"
