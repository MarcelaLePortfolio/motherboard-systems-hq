#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 333 governance reporting verification =="

echo
echo "-- git status --"
git status --short

echo
echo "-- validating allowed file surface --"
CHANGED_FILES="$(git diff --name-only HEAD~1..HEAD || true)"
echo "$CHANGED_FILES"

if echo "$CHANGED_FILES" | grep -E '^(src/governance/|src/governance_visibility/|src/governance_traceability/|runtime/|reducers/|workers/|public/js/)' >/dev/null 2>&1; then
  echo "FAIL: protected runtime or governance surface was modified."
  exit 1
fi

echo
echo "-- running governance reporting tests --"
npx vitest run \
  tests/governance_reporting/governance_reporting_model.test.ts \
  tests/governance_reporting/governance_reporting_formatter.test.ts \
  tests/governance_reporting/governance_reporting_builder.test.ts \
  tests/governance_reporting/governance_reporting_contract.test.ts

echo
echo "-- verifying governance reporting file set --"
test -f src/governance_reporting/governance_reporting_model.ts
test -f src/governance_reporting/governance_reporting_formatter.ts
test -f src/governance_reporting/governance_reporting_builder.ts
test -f src/governance_reporting/governance_reporting_contract.ts
test -f src/governance_reporting/index.ts

echo
echo "PASS: Phase 333 governance reporting layer remains read-only, deterministic, and isolated."
