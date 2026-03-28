#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 340 governance operator session verification =="

echo
echo "-- git status --"
git status --short

echo
echo "-- validating allowed file surface --"
CHANGED_FILES="$(git diff --name-only HEAD~1..HEAD || true)"
echo "$CHANGED_FILES"

if echo "$CHANGED_FILES" | grep -E '^(src/governance/|src/governance_visibility/|src/governance_traceability/|src/governance_reporting/|src/governance_digest/|src/governance_operator_packet/|src/governance_operator_manifest/|src/governance_operator_briefing/|src/governance_operator_console/|src/governance_operator_handoff/|runtime/|reducers/|workers/|public/js/)' >/dev/null 2>&1; then
  echo "FAIL: protected runtime or governance surface was modified."
  exit 1
fi

echo
echo "-- running governance operator session tests --"
npx vitest run \
  tests/governance_operator_session/governance_operator_session_model.test.ts \
  tests/governance_operator_session/governance_operator_session_formatter.test.ts \
  tests/governance_operator_session/governance_operator_session_builder.test.ts \
  tests/governance_operator_session/governance_operator_session_contract.test.ts

echo
echo "-- verifying governance operator session file set --"
test -f src/governance_operator_session/governance_operator_session_model.ts
test -f src/governance_operator_session/governance_operator_session_formatter.ts
test -f src/governance_operator_session/governance_operator_session_builder.ts
test -f src/governance_operator_session/governance_operator_session_contract.ts
test -f src/governance_operator_session/index.ts

echo
echo "PASS: Phase 340 governance operator session layer remains read-only, deterministic, and isolated."
