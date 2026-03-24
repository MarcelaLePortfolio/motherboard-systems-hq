#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

FILE="runtime/runtime_bootstrap.ts"

echo "Phase 156.2 — Bootstrap Export Boundary Validation"
echo "=================================================="
echo

if [[ ! -f "$FILE" ]]; then
  echo "FAIL: runtime bootstrap file missing"
  exit 1
fi

echo "[1/9] RuntimeServices interface exported"
grep -q 'export interface RuntimeServices' "$FILE"

echo "[2/9] RuntimeBootstrap class exported"
grep -q 'export class RuntimeBootstrap' "$FILE"

echo "[3/9] createRuntimeBootstrap factory exported"
grep -q 'export function createRuntimeBootstrap' "$FILE"

echo "[4/9] registry service exposed through RuntimeServices"
grep -q 'registry: RegistryRuntimeContainer' "$FILE"

echo "[5/9] services getter present"
grep -q 'getServices()' "$FILE"

echo "[6/9] no direct store export"
if grep -q 'RegistryStateStore' "$FILE"; then
  echo "FAIL: RegistryStateStore referenced in runtime bootstrap"
  exit 1
fi

echo "[7/9] no direct mutation coordinator export"
if grep -q 'RegistryMutationCoordinator' "$FILE"; then
  echo "FAIL: RegistryMutationCoordinator referenced in runtime bootstrap"
  exit 1
fi

echo "[8/9] no direct owner surface export"
if grep -q 'RegistryOwnerSurface' "$FILE"; then
  echo "FAIL: RegistryOwnerSurface referenced in runtime bootstrap"
  exit 1
fi

echo "[9/9] no public fields exposing runtime internals"
if grep -q 'public services' "$FILE"; then
  echo "FAIL: public services field detected"
  exit 1
fi

echo
echo "PASS: runtime bootstrap export boundary validated"
