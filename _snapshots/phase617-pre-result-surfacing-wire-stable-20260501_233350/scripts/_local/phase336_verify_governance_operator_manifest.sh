#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 336 governance operator manifest verification =="

echo
echo "-- git status --"
git status --short

echo
echo "-- validating allowed file surface --"
CHANGED_FILES="$(git diff --name-only HEAD~1..HEAD || true)"
echo "$CHANGED_FILES"

if echo "$CHANGED_FILES" | grep -E '^(src/governance/|src/governance_visibility/|src/governance_traceability/|src/governance_reporting/|src/governance_digest/|src/governance_operator_packet/|runtime/|reducers/|workers/|public/js/)' >/dev/null 2>&1; then
  echo "FAIL: protected runtime or governance surface was modified."
  exit 1
fi

echo
echo "-- running governance operator manifest tests --"
npx vitest run \
  tests/governance_operator_manifest/governance_operator_manifest_model.test.ts \
  tests/governance_operator_manifest/governance_operator_manifest_formatter.test.ts \
  tests/governance_operator_manifest/governance_operator_manifest_builder.test.ts \
  tests/governance_operator_manifest/governance_operator_manifest_contract.test.ts

echo
echo "-- verifying governance operator manifest file set --"
test -f src/governance_operator_manifest/governance_operator_manifest_model.ts
test -f src/governance_operator_manifest/governance_operator_manifest_formatter.ts
test -f src/governance_operator_manifest/governance_operator_manifest_builder.ts
test -f src/governance_operator_manifest/governance_operator_manifest_contract.ts
test -f src/governance_operator_manifest/index.ts

echo
echo "PASS: Phase 336 governance operator manifest layer remains read-only, deterministic, and isolated."
