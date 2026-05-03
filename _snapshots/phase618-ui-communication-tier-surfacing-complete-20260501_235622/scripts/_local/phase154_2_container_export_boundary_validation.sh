#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

FILE="runtime/registry_runtime_container.ts"

echo "Phase 154.2 — Runtime Container Export Boundary Validation"
echo "==========================================================="
echo

if [[ ! -f "$FILE" ]]; then
  echo "FAIL: runtime container missing"
  exit 1
fi

echo "[1/9] inspection surface export present"
grep -q 'getRegistryInspectionSurface' "$FILE"

echo "[2/9] workflow surface export present"
grep -q 'getRegistryWorkflowSurface' "$FILE"

echo "[3/9] summary surface export present"
grep -q 'getRegistrySummarySurface' "$FILE"

echo "[4/9] state store NOT exported"
if grep -q 'getRegistryStateStore' "$FILE"; then
  echo "FAIL: state store export detected"
  exit 1
fi

echo "[5/9] mutation coordinator NOT exported"
if grep -q 'getRegistryMutationCoordinator' "$FILE"; then
  echo "FAIL: mutation coordinator export detected"
  exit 1
fi

echo "[6/9] owner surface NOT exported"
if grep -q 'getRegistryOwnerSurface' "$FILE"; then
  echo "FAIL: owner surface export detected"
  exit 1
fi

echo "[7/9] no public fields exposing registry internals"
if grep -q 'public store' "$FILE"; then
  echo "FAIL: store exposed publicly"
  exit 1
fi

echo "[8/9] only approved getters exist"
COUNT=$(grep -c 'getRegistry' "$FILE")

if [[ "$COUNT" -ne 3 ]]; then
  echo "FAIL: unexpected number of registry getters ($COUNT)"
  exit 1
fi

echo "[9/9] private fields remain private"
grep -q 'private store' "$FILE"
grep -q 'private workflow' "$FILE"
grep -q 'private inspection' "$FILE"

echo
echo "PASS: container export boundary contract validated"

