#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="4b6664742"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== IMPLEMENTATION PRECHECK ===\n'
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_ATTEMPT=0"
echo "CURRENT_STEP=EXACT_CONTRACT_INSPECTION"
echo "LIVE_VALIDATION_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTO_ADVANCE=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== EXISTING DELEGATION CLIENT ADAPTER ===\n'
sed -n '1,220p' client/src/approvals/governanceDelegationApi.ts

printf '\n=== EXISTING DELEGATION CLIENT TEST ===\n'
sed -n '1,240p' client/src/approvals/governanceDelegationApi.test.ts

printf '\n=== CANONICAL PACKAGE READ MODEL ===\n'
sed -n '1,240p' client/src/approvals/canonicalPackageReadApi.ts

printf '\n=== EXACT DELEGATED PACKAGE UI SURFACE ===\n'
sed -n '620,875p' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== VALIDATION ROUTE BODY CONTRACT ===\n'
sed -n '1,190p' server/routes/governance-validation-route.ts

printf '\n=== VALIDATION RESULT CONTRACT ===\n'
sed -n '1,180p' server/validation/production-validation-entry-point.ts

printf '\n=== CLIENT TEST COMMANDS / TOOLING ===\n'
cat client/package.json
printf '\n--- ROOT PACKAGE TEST TOOLING ---\n'
cat package.json

printf '\n=== TARGET BASELINE STATE ===\n'
for f in \
  client/src/approvals/governanceValidationApi.ts \
  client/src/approvals/governanceValidationApi.test.ts \
  client/src/approvals/ApprovalsWorkspace.tsx
do
  if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
    echo "TRACKED=$f"
    echo "BLOB=$(git rev-parse HEAD:"$f")"
    test -z "$(git diff -- "$f")"
  elif test -e "$f"; then
    echo "UNEXPECTED_UNTRACKED_TARGET=$f"
    exit 1
  else
    echo "EXPECTED_NEW=$f"
  fi
done

printf '\n=== ATTEMPT 1 BOUNDARY ===\n'
echo "EXPECTED_NEW_FILES=2"
echo "EXPECTED_EXISTING_FILES_MODIFIED=1"
echo "SERVER_FILES_MODIFIED=0"
echo "DATABASE_FILES_MODIFIED=0"
echo "EXPLICIT_CLICK_REQUIRED=YES"
echo "AUTOMATIC_VALIDATION=NO"
echo "LIVE_PROOF_MUTATION=NO"
echo "DOWNSTREAM_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== WORKTREE — PRESERVE ===\n'
git status --short

printf '\nOPERATOR_VALIDATION_EXACT_CONTRACT_INSPECTION=COMPLETE\n'
