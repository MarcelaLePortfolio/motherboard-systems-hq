#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 338 governance operator console verification =="

echo
echo "-- git status --"
git status --short

echo
echo "-- validating allowed file surface --"
CHANGED_FILES="$(git diff --name-only HEAD~1..HEAD || true)"
echo "$CHANGED_FILES"

if echo "$CHANGED_FILES" | grep -E '^(src/governance/|src/governance_visibility/|src/governance_traceability/|src/governance_reporting/|src/governance_digest/|src/governance_operator_packet/|src/governance_operator_manifest/|src/governance_operator_briefing/|runtime/|reducers/|workers/|public/js/)' >/dev/null 2>&1; then
  echo "FAIL: protected runtime or governance surface was modified."
  exit 1
fi

echo
echo "-- running governance operator console tests --"
npx vitest run \
  tests/governance_operator_console/governance_operator_console_model.test.ts \
  tests/governance_operator_console/governance_operator_console_formatter.test.ts \
  tests/governance_operator_console/governance_operator_console_builder.test.ts \
  tests/governance_operator_console/governance_operator_console_contract.test.ts

echo
echo "-- verifying governance operator console file set --"
test -f src/governance_operator_console/governance_operator_console_model.ts
test -f src/governance_operator_console/governance_operator_console_formatter.ts
test -f src/governance_operator_console/governance_operator_console_builder.ts
test -f src/governance_operator_console/governance_operator_console_contract.ts
test -f src/governance_operator_console/index.ts

echo
echo "PASS: Phase 338 governance operator console layer remains read-only, deterministic, and isolated."
