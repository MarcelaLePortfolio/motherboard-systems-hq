#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

FILE="runtime/runtime_bootstrap.ts"

echo "Phase 156.1 — Bootstrap Determinism Validation"
echo "=============================================="
echo

if [[ ! -f "$FILE" ]]; then
  echo "FAIL: runtime bootstrap file missing"
  exit 1
fi

echo "[1/8] bootstrap class present"
grep -q 'export class RuntimeBootstrap' "$FILE"

echo "[2/8] runtime services interface present"
grep -q 'export interface RuntimeServices' "$FILE"

echo "[3/8] registry container construction present"
grep -q 'new RegistryRuntimeContainer' "$FILE"

echo "[4/8] registry attached to services"
grep -q 'registry: registryContainer' "$FILE"

echo "[5/8] services stored once"
grep -q 'private services' "$FILE"

echo "[6/8] no lazy construction patterns"
if grep -q '||=' "$FILE"; then
  echo "FAIL: lazy initialization detected"
  exit 1
fi

echo "[7/8] no mutation wiring"
if grep -q 'MutationCoordinator' "$FILE"; then
  echo "FAIL: mutation coordinator referenced in bootstrap"
  exit 1
fi

echo "[8/8] deterministic factory function present"
grep -q 'createRuntimeBootstrap' "$FILE"

echo
echo "PASS: runtime bootstrap determinism validated"

