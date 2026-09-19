#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="0fd52d2cd"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== PRESERVE KNOWN UNRELATED WORKTREE DRIFT ===\n'
git status --short

printf '\n=== VERIFY AUTHORIZED TEST FILE MUTATIONS EXIST ===\n'
test -n "$(git diff -- db/approval-request-model-assembler.test.ts)"
test -n "$(git diff -- routes/api-approval-request.test.ts)"

git diff --check -- \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts

printf '\n=== VERIFY PROTECTED PRODUCT BOUNDARIES UNCHANGED ===\n'
git diff --exit-code -- \
  db/approval-request-model-assembler.ts \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/ApprovalsWorkspace.tsx \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  server/execution \
  server/operational \
  db/governance-execution-approvals.ts \
  db/governance-execution-scopes.ts \
  db/governance-execution-reconciliation-persistence.ts

printf '\n=== TARGETED TESTS ===\n'
npx tsx --test \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts

printf '\n=== SERVER BUILD ===\n'
npm run build

printf '\n=== CLIENT BUILD ===\n'
npm --prefix client run build

printf '\n=== FINAL VALIDATION CLASSIFICATION ===\n'
echo "TARGETED_TESTS=PASS"
echo "SERVER_BUILD=PASS"
echo "CLIENT_BUILD=PASS"
echo "KNOWN_UNRELATED_DRIFT_PRESERVED=YES"
echo "PRODUCT_CODE_CHANGED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "TEST_FIXTURE_REPAIR_VALIDATED=YES"
echo "NEXT_ACTION=COMMIT_AUTHORIZED_TEST_FIXTURE_REPAIR_ONLY"
echo "CLEAR_STOPPING_POINT=YES"
