#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 337 governance operator briefing verification =="

echo
echo "-- git status --"
git status --short

echo
echo "-- validating allowed file surface --"
CHANGED_FILES="$(git diff --name-only HEAD~1..HEAD || true)"
echo "$CHANGED_FILES"

if echo "$CHANGED_FILES" | grep -E '^(src/governance/|src/governance_visibility/|src/governance_traceability/|src/governance_reporting/|src/governance_digest/|src/governance_operator_packet/|src/governance_operator_manifest/|runtime/|reducers/|workers/|public/js/)' >/dev/null 2>&1; then
  echo "FAIL: protected runtime or governance surface was modified."
  exit 1
fi

echo
echo "-- running governance operator briefing tests --"
npx vitest run \
  tests/governance_operator_briefing/governance_operator_briefing_model.test.ts \
  tests/governance_operator_briefing/governance_operator_briefing_formatter.test.ts \
  tests/governance_operator_briefing/governance_operator_briefing_builder.test.ts \
  tests/governance_operator_briefing/governance_operator_briefing_contract.test.ts

echo
echo "-- verifying governance operator briefing file set --"
test -f src/governance_operator_briefing/governance_operator_briefing_model.ts
test -f src/governance_operator_briefing/governance_operator_briefing_formatter.ts
test -f src/governance_operator_briefing/governance_operator_briefing_builder.ts
test -f src/governance_operator_briefing/governance_operator_briefing_contract.ts
test -f src/governance_operator_briefing/index.ts

echo
echo "PASS: Phase 337 governance operator briefing layer remains read-only, deterministic, and isolated."
