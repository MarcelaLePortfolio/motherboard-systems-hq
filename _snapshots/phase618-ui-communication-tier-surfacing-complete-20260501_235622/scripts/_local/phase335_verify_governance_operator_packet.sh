#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 335 governance operator packet verification =="

echo
echo "-- git status --"
git status --short

echo
echo "-- validating allowed file surface --"
CHANGED_FILES="$(git diff --name-only HEAD~1..HEAD || true)"
echo "$CHANGED_FILES"

if echo "$CHANGED_FILES" | grep -E '^(src/governance/|src/governance_visibility/|src/governance_traceability/|src/governance_reporting/|src/governance_digest/|runtime/|reducers/|workers/|public/js/)' >/dev/null 2>&1; then
  echo "FAIL: protected runtime or governance surface was modified."
  exit 1
fi

echo
echo "-- running governance operator packet tests --"
npx vitest run \
  tests/governance_operator_packet/governance_operator_packet_model.test.ts \
  tests/governance_operator_packet/governance_operator_packet_formatter.test.ts \
  tests/governance_operator_packet/governance_operator_packet_builder.test.ts \
  tests/governance_operator_packet/governance_operator_packet_contract.test.ts

echo
echo "-- verifying governance operator packet file set --"
test -f src/governance_operator_packet/governance_operator_packet_model.ts
test -f src/governance_operator_packet/governance_operator_packet_formatter.ts
test -f src/governance_operator_packet/governance_operator_packet_builder.ts
test -f src/governance_operator_packet/governance_operator_packet_contract.ts
test -f src/governance_operator_packet/index.ts

echo
echo "PASS: Phase 335 governance operator packet layer remains read-only, deterministic, and isolated."
