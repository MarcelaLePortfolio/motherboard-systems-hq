#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="0e8c4ff7a"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== THIRD AND FINAL IMPLEMENTATION HYPOTHESIS ===\n'
echo "SERVER_ASSEMBLER_PARTIAL_IMPLEMENTATION=PRESENT"
echo "CLIENT_API_PARTIAL_IMPLEMENTATION=PRESENT"
echo "EXACT_WORKSPACE_CALLSITE=PROVEN"
echo "THIS_ATTEMPT_SCOPE=WORKSPACE_HANDOFF_PLUS_VALIDATION_ONLY"

python3 <<'PY'
from pathlib import Path

p = Path("client/src/approvals/ApprovalsWorkspace.tsx")
s = p.read_text()

old = '''      try {
        await approveCanonicalPackage(
          request.draft_package_id,
        );
        await onApproved();
'''

new = '''      try {
        await approveCanonicalPackage(
          request.draft_package_id,
          request.draft_revision_id,
        );
        await onApproved();
'''

if old not in s:
    raise SystemExit("Exact verified ApprovalsWorkspace callsite no longer matches")

s = s.replace(old, new, 1)
p.write_text(s)
PY

printf '\n=== VERIFY COMPLETE HANDOFF ===\n'
grep -q 'createDraftRevisionForApprovalReview' \
  db/approval-request-model-assembler.ts
grep -q 'draft_revision_id: revision.draft_revision_id' \
  db/approval-request-model-assembler.ts
grep -q 'draft_revision_id: string;' \
  client/src/approvals/approvalRequestApi.ts
grep -q 'draft_revision_id: normalizedDraftRevisionId' \
  client/src/approvals/approvalRequestApi.ts
grep -q 'request.draft_revision_id' \
  client/src/approvals/ApprovalsWorkspace.tsx

git diff --check

git diff -- \
  client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== VERIFY PROTECTED BOUNDARIES UNCHANGED ===\n'
git diff --exit-code -- \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  db/matilda-draft-revision-runtime.ts \
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

printf '\n=== FINAL STATIC VALIDATION ===\n'
echo "DRAFT_REVISION_CREATED_OR_REUSED_AT_REVIEW_BOUNDARY=YES"
echo "DRAFT_REVISION_EXPOSED_IN_READ_MODEL=YES"
echo "CLIENT_API_ACCEPTS_DRAFT_REVISION_ID=YES"
echo "CLIENT_API_SUBMITS_DRAFT_REVISION_ID=YES"
echo "WORKSPACE_PASSES_EXACT_DRAFT_REVISION_ID=YES"
echo "CANONICAL_BOUNDARY_CHANGED=NO"
echo "DELEGATION_CHANGED=NO"
echo "VALIDATION_CHANGED=NO"
echo "ENVELOPE_CHANGED=NO"
echo "EXECUTION_CHANGED=NO"
echo "GOVERNANCE_CHANGED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "STATIC_VALIDATION_COMPLETE=YES"
echo "NEXT_ACTION=RUNTIME_VALIDATE_NATURAL_APPROVAL_FLOW"
echo "CLEAR_STOPPING_POINT=YES"
