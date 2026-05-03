#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

FILE="runtime/registry_runtime_container.ts"

echo "Phase 154.1 — Container Determinism Validation"
echo "=============================================="
echo

if [[ ! -f "$FILE" ]]; then
  echo "FAIL: missing $FILE"
  exit 1
fi

echo "[1/8] runtime container file present"
grep -q 'export class RegistryRuntimeContainer' "$FILE"

echo "[2/8] single store field declared"
grep -q 'private store: RegistryStateStore' "$FILE"

echo "[3/8] read-only export methods present"
grep -q 'getRegistryInspectionSurface' "$FILE"
grep -q 'getRegistryWorkflowSurface' "$FILE"
grep -q 'getRegistrySummarySurface' "$FILE"

echo "[4/8] no state store export"
if grep -q 'getRegistryStateStore' "$FILE"; then
  echo "FAIL: forbidden getRegistryStateStore export detected"
  exit 1
fi

echo "[5/8] no mutation coordinator export"
if grep -q 'getRegistryMutationCoordinator' "$FILE"; then
  echo "FAIL: forbidden getRegistryMutationCoordinator export detected"
  exit 1
fi

echo "[6/8] no owner surface export"
if grep -q 'getRegistryOwnerSurface' "$FILE"; then
  echo "FAIL: forbidden getRegistryOwnerSurface export detected"
  exit 1
fi

echo "[7/8] deterministic constructor wiring present"
grep -q 'new RegistryStateStore()' "$FILE"
grep -q 'new RegistryReadSurface' "$FILE"
grep -q 'new RegistryVisibilityDiagnostics' "$FILE"
grep -q 'new RegistrySummarySurface' "$FILE"
grep -q 'new RegistryOperatorInspection' "$FILE"

echo "[8/8] no lazy initialization patterns"
if grep -q '||=' "$FILE"; then
  echo "FAIL: lazy initialization pattern detected"
  exit 1
fi

echo
echo "PASS: runtime container determinism contract validated"
