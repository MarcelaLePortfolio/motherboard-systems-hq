#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 334 governance digest verification =="

echo
echo "-- git status --"
git status --short

echo
echo "-- validating allowed file surface --"
CHANGED_FILES="$(git diff --name-only HEAD~1..HEAD || true)"
echo "$CHANGED_FILES"

if echo "$CHANGED_FILES" | grep -E '^(src/governance/|src/governance_visibility/|src/governance_traceability/|src/governance_reporting/|runtime/|reducers/|workers/|public/js/)' >/dev/null 2>&1; then
  echo "FAIL: protected runtime or governance surface was modified."
  exit 1
fi

echo
echo "-- running governance digest tests --"
npx vitest run \
  tests/governance_digest/governance_digest_model.test.ts \
  tests/governance_digest/governance_digest_formatter.test.ts \
  tests/governance_digest/governance_digest_builder.test.ts \
  tests/governance_digest/governance_digest_contract.test.ts

echo
echo "-- verifying governance digest file set --"
test -f src/governance_digest/governance_digest_model.ts
test -f src/governance_digest/governance_digest_formatter.ts
test -f src/governance_digest/governance_digest_builder.ts
test -f src/governance_digest/governance_digest_contract.ts
test -f src/governance_digest/index.ts

echo
echo "PASS: Phase 334 governance digest layer remains read-only, deterministic, and isolated."
