#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "== Phase 331 governance visibility verification =="

echo
echo "-- git status --"
git status --short

echo
echo "-- validating allowed file surface --"
CHANGED_FILES="$(git diff --name-only HEAD~4..HEAD || true)"
echo "$CHANGED_FILES"

if echo "$CHANGED_FILES" | grep -E '^(src/governance/|runtime/|reducers/|workers/|public/js/)' >/dev/null 2>&1; then
  echo "FAIL: protected runtime or governance execution surface was modified."
  exit 1
fi

echo
echo "-- running governance visibility tests --"
npx vitest run \
  tests/governance_visibility/governance_visibility_model.test.ts \
  tests/governance_visibility/governance_visibility_formatter.test.ts \
  tests/governance_visibility/governance_visibility_snapshot.test.ts \
  tests/governance_visibility/governance_visibility_contract.test.ts

echo
echo "-- verifying governance visibility file set --"
test -f src/governance_visibility/governance_visibility_model.ts
test -f src/governance_visibility/governance_visibility_formatter.ts
test -f src/governance_visibility/governance_visibility_snapshot.ts
test -f src/governance_visibility/governance_visibility_contract.ts
test -f src/governance_visibility/index.ts

echo
echo "PASS: Phase 331 governance visibility layer remains read-only, deterministic, and isolated."
