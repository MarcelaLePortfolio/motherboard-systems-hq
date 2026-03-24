#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 129 governance routing smoke starting..."

if ! grep -q "routeGovernanceOutcome" src/governance/governanceExecutionRouting.ts; then
  echo "FAIL: routing function missing"
  exit 1
fi

if ! grep -q "classifyGovernanceRouting" src/governance/governanceExecutionRoutingClassifier.ts; then
  echo "FAIL: classifier missing"
  exit 1
fi

if ! grep -q "proveGovernanceRoutingDeterminism" src/governance/governanceExecutionRoutingProof.ts; then
  echo "FAIL: proof surface missing"
  exit 1
fi

if ! grep -q "export \*" src/governance/index.ts; then
  echo "FAIL: barrel wiring missing"
  exit 1
fi

echo "Phase 129 governance routing smoke PASS"

