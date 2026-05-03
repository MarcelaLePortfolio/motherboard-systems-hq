#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 332 governance traceability verification =="

echo
echo "-- git status --"
git status --short

echo
echo "-- validating allowed file surface --"
CHANGED_FILES="$(git diff --name-only HEAD~1..HEAD || true)"
echo "$CHANGED_FILES"

if echo "$CHANGED_FILES" | grep -E '^(src/governance/|src/governance_visibility/|runtime/|reducers/|workers/|public/js/)' >/dev/null 2>&1; then
  echo "FAIL: protected runtime or governance surface was modified."
  exit 1
fi

echo
echo "-- running governance traceability tests --"
npx vitest run \
  tests/governance_traceability/governance_traceability_model.test.ts \
  tests/governance_traceability/governance_traceability_formatter.test.ts \
  tests/governance_traceability/governance_traceability_snapshot.test.ts \
  tests/governance_traceability/governance_traceability_contract.test.ts

echo
echo "-- verifying governance traceability file set --"
test -f src/governance_traceability/governance_traceability_model.ts
test -f src/governance_traceability/governance_traceability_formatter.ts
test -f src/governance_traceability/governance_traceability_snapshot.ts
test -f src/governance_traceability/governance_traceability_contract.ts
test -f src/governance_traceability/index.ts

echo
echo "PASS: Phase 332 governance traceability layer remains read-only, deterministic, and isolated."
