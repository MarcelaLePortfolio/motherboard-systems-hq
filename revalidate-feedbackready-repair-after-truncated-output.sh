#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="d92f6a013"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

TARGET="client/src/approvals/ApprovalsWorkspace.tsx"

printf '\n=== VERIFY AUTHORIZED WORKTREE STATE ===\n'
test -n "$(git diff -- "$TARGET")"

if grep -n -E '\bfeedbackReady\b|\bsetFeedbackReady\b' "$TARGET"; then
  echo "FEEDBACKREADY_RESIDUE=YES"
  exit 1
fi

git diff --check -- "$TARGET"

printf '\n=== TARGETED APPROVAL TESTS ===\n'
npx tsx --test \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts

printf '\n=== SERVER BUILD ===\n'
npm run build

printf '\n=== CLIENT BUILD ===\n'
npm --prefix client run build

printf '\n=== VERIFY PROTECTED BOUNDARIES ===\n'
git diff --exit-code -- \
  db/approval-request-model-assembler.ts \
  client/src/approvals/approvalRequestApi.ts \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  server/execution \
  server/operational \
  db/governance-execution-approvals.ts \
  db/governance-execution-scopes.ts \
  db/governance-execution-reconciliation-persistence.ts

printf '\n=== VALIDATION COMPLETE ===\n'
echo "TARGETED_APPROVAL_TESTS=PASS"
echo "SERVER_BUILD=PASS"
echo "CLIENT_BUILD=PASS"
echo "FEEDBACKREADY_REPAIR_VALIDATED=YES"
echo "APPROVAL_HANDOFF_SEMANTICS_CHANGED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=COMMIT_AUTHORIZED_CLIENT_BUILD_REPAIR"
echo "CLEAR_STOPPING_POINT=YES"
