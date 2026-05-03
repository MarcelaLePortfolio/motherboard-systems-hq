#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

FILE="runtime/operator_registry_access.ts"

echo "Phase 161.1 — Operator Registry Access Validation"
echo "================================================"
echo

fail() {
  echo "FAIL: $1"
  exit 1
}

echo "[1/10] helper file exists"
[[ -f "$FILE" ]] || fail "operator_registry_access.ts missing"

echo "[2/10] inspection helper exists"
grep -q 'getRegistryInspection' "$FILE" || fail "inspection helper missing"

echo "[3/10] workflow helper exists"
grep -q 'getRegistryWorkflow' "$FILE" || fail "workflow helper missing"

echo "[4/10] summary helper exists"
grep -q 'getRegistrySummary' "$FILE" || fail "summary helper missing"

echo "[5/10] helpers only access approved container getters"
grep -q 'getRegistryInspectionSurface' "$FILE" || fail "inspection surface access missing"
grep -q 'getRegistryWorkflowSurface' "$FILE" || fail "workflow surface access missing"
grep -q 'getRegistrySummarySurface' "$FILE" || fail "summary surface access missing"

echo "[6/10] no RegistryStateStore access"
if grep -q 'RegistryStateStore' "$FILE"; then
  fail "store referenced"
fi

echo "[7/10] no mutation coordinator access"
if grep -q 'RegistryMutationCoordinator' "$FILE"; then
  fail "mutation coordinator referenced"
fi

echo "[8/10] no owner surface access"
if grep -q 'RegistryOwnerSurface' "$FILE"; then
  fail "owner surface referenced"
fi

echo "[9/10] no caching patterns"
if grep -q 'let ' "$FILE"; then
  fail "unexpected mutable variable detected"
fi

echo "[10/10] no logic beyond forwarding"
COUNT=$(grep -c 'return runtime' "$FILE")
[[ "$COUNT" -eq 3 ]] || fail "unexpected helper logic detected"

echo
echo "PASS: operator registry access helpers validated"
echo "Access boundary remains sealed"

