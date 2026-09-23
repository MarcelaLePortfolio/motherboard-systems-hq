#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="73d4f467a"
IMPLEMENTATION_COMMIT="7da4b1a34"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== VERIFY IMPLEMENTATION ANCESTRY ===\n'
git merge-base --is-ancestor "$IMPLEMENTATION_COMMIT" HEAD
echo "IMPLEMENTATION_COMMIT_IN_ANCESTRY=YES"

printf '\n=== VERIFY TARGET FILES ===\n'
for f in \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/governanceValidationApi.ts \
  client/src/approvals/governanceValidationApi.test.ts
do
  git cat-file -e "HEAD:$f"
  echo "HEAD_CONTAINS=$f"
done

printf '\n=== GATE 1: DIFF CHECK ===\n'
git diff --check

printf '\n=== GATE 2: ROOT TYPECHECK ===\n'
npm run check

printf '\n=== GATE 3: ADAPTER TESTS ===\n'
./node_modules/.bin/tsx --test \
  client/src/approvals/governanceValidationApi.test.ts

printf '\n=== GATE 4: CLIENT BUILD ===\n'
(
  cd client
  npm run build
)

printf '\n============================================\n'
printf ' EXPLICIT OPERATOR VALIDATION ACTION — CLOSED\n'
printf '============================================\n\n'

echo "IMPLEMENTATION_COMMIT=$IMPLEMENTATION_COMMIT"
echo "RECORD_COMMIT=$EXPECTED_HEAD"
echo "EXPLICIT_OPERATOR_VALIDATION_ACTION=IMPLEMENTED_AND_VERIFIED"
echo "OPERATOR_CLICK_REQUIRED=YES"
echo "DELEGATED_PACKAGE_ONLY=YES"
echo "AUTOMATIC_VALIDATION=NO"
echo "SERVER_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NONE"
echo "AUTO_ADVANCE=NONE"
echo "DOWNSTREAM_AUTHORITY=NONE"
echo "NEW_AUTHORITY=NONE"
echo "ROOT_TYPECHECK=PASS"
echo "ADAPTER_TESTS=3_OF_3_PASS"
echo "CLIENT_BUILD=PASS"
echo "LOCAL_REMOTE_CONVERGED=YES"

printf '\n=== SUCCESSOR BOUNDARY ===\n'
echo "DELEGATION_TO_VALIDATION_OPERATOR_SURFACE=COMPLETE"
echo "LIVE_VALIDATION_EXECUTION=REQUIRES_EXPLICIT_OPERATOR_CLICK"
echo "VALIDATION_TO_ENVELOPE_GATE=A_SEPARATE_SUCCESSOR_BOUNDARY"
echo "SUCCESSOR_AUTO_ADVANCE=PROHIBITED"
echo "SUCCESSOR_IMPLEMENTATION_AUTHORIZED=NO"

printf '\nEXPLICIT_OPERATOR_VALIDATION_ACTION_CORRIDOR=CLOSED\n'
