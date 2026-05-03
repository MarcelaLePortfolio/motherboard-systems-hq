#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 346 governance operator logbook verification =="

echo
echo "-- git status --"
git status --short

echo
echo "-- validating allowed file surface --"
CHANGED_FILES="$(git diff --name-only HEAD~1..HEAD || true)"
echo "$CHANGED_FILES"

if echo "$CHANGED_FILES" | grep -E '^(src/governance/|src/governance_visibility/|src/governance_traceability/|src/governance_reporting/|src/governance_digest/|src/governance_operator_packet/|src/governance_operator_manifest/|src/governance_operator_briefing/|src/governance_operator_console/|src/governance_operator_handoff/|src/governance_operator_session/|src/governance_operator_snapshot/|src/governance_operator_bundle/|src/governance_operator_export/|src/governance_operator_archive/|src/governance_operator_record/|runtime/|reducers/|workers/|public/js/)' >/dev/null 2>&1; then
  echo "FAIL: protected runtime or governance surface was modified."
  exit 1
fi

echo
echo "-- running governance operator logbook tests --"
npx vitest run \
  tests/governance_operator_logbook/governance_operator_logbook_model.test.ts \
  tests/governance_operator_logbook/governance_operator_logbook_formatter.test.ts \
  tests/governance_operator_logbook/governance_operator_logbook_builder.test.ts \
  tests/governance_operator_logbook/governance_operator_logbook_contract.test.ts

echo
echo "-- verifying governance operator logbook file set --"
test -f src/governance_operator_logbook/governance_operator_logbook_model.ts
test -f src/governance_operator_logbook/governance_operator_logbook_formatter.ts
test -f src/governance_operator_logbook/governance_operator_logbook_builder.ts
test -f src/governance_operator_logbook/governance_operator_logbook_contract.ts
test -f src/governance_operator_logbook/index.ts

echo
echo "PASS: Phase 346 governance operator logbook layer remains read-only, deterministic, and isolated."
