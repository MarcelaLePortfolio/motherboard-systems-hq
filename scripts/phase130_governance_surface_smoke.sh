#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 130 governance outcome surface smoke starting..."

if ! grep -q "GovernanceOutcomeSurface" src/governance/governanceOutcomeSurfaceTypes.ts; then
  echo "FAIL: surface types missing"
  exit 1
fi

if ! grep -q "buildGovernanceOutcomeSurface" src/governance/governanceOutcomeSurfaceBuilder.ts; then
  echo "FAIL: surface builder missing"
  exit 1
fi

if ! grep -q "proveGovernanceOutcomeSurface" src/governance/governanceOutcomeSurfaceProof.ts; then
  echo "FAIL: surface proof missing"
  exit 1
fi

if ! grep -q "governanceOutcomeSurface" src/governance/index.ts; then
  echo "FAIL: barrel exposure missing"
  exit 1
fi

echo "Phase 130 governance outcome surface smoke PASS"

