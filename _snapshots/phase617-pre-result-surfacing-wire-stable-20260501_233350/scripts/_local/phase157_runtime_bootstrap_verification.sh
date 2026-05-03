#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BOOTSTRAP="runtime/runtime_bootstrap.ts"
CONTAINER="runtime/registry_runtime_container.ts"

echo "Phase 157 — Runtime Bootstrap Verification Pass"
echo "==============================================="
echo

fail() {
  echo "FAIL: $1"
  exit 1
}

echo "[1/10] bootstrap file exists"
[[ -f "$BOOTSTRAP" ]] || fail "runtime_bootstrap.ts missing"

echo "[2/10] container file exists"
[[ -f "$CONTAINER" ]] || fail "registry_runtime_container.ts missing"

echo "[3/10] bootstrap imports container"
grep -q 'RegistryRuntimeContainer' "$BOOTSTRAP" || fail "container not imported"

echo "[4/10] container constructed once"
COUNT=$(grep -c 'new RegistryRuntimeContainer' "$BOOTSTRAP")
[[ "$COUNT" -eq 1 ]] || fail "container constructed multiple times"

echo "[5/10] registry attached to services only"
grep -q 'registry: registryContainer' "$BOOTSTRAP" || fail "registry not attached correctly"

echo "[6/10] no registry internals referenced"
if grep -q 'RegistryStateStore' "$BOOTSTRAP"; then fail "store leaked"; fi
if grep -q 'RegistryMutationCoordinator' "$BOOTSTRAP"; then fail "coordinator leaked"; fi
if grep -q 'RegistryOwnerSurface' "$BOOTSTRAP"; then fail "owner surface leaked"; fi

echo "[7/10] services getter present"
grep -q 'getServices()' "$BOOTSTRAP" || fail "services getter missing"

echo "[8/10] container exports only read surfaces"
grep -q 'getRegistryInspectionSurface' "$CONTAINER" || fail "inspection getter missing"
grep -q 'getRegistryWorkflowSurface' "$CONTAINER" || fail "workflow getter missing"
grep -q 'getRegistrySummarySurface' "$CONTAINER" || fail "summary getter missing"

echo "[9/10] container does NOT export mutation surfaces"
if grep -q 'getRegistryStateStore' "$CONTAINER"; then fail "store export found"; fi
if grep -q 'getRegistryMutationCoordinator' "$CONTAINER"; then fail "coordinator export found"; fi
if grep -q 'getRegistryOwnerSurface' "$CONTAINER"; then fail "owner export found"; fi

echo "[10/10] deterministic construction patterns verified"
grep -q 'new RegistryStateStore()' "$CONTAINER" || fail "store not constructed"
grep -q 'new RegistryReadSurface' "$CONTAINER" || fail "read surface missing"

echo
echo "PASS: runtime bootstrap verification successful"
echo "Registry integration is deterministic and sealed"

