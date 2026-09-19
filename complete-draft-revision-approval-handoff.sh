#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="fecf526f5"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== PRESERVE VERIFIED PARTIAL IMPLEMENTATION ===\n'
grep -q 'createDraftRevisionForApprovalReview' \
  db/approval-request-model-assembler.ts
grep -q 'draft_revision_id: string;' \
  db/approval-request-model-assembler.ts
grep -q 'draft_revision_id: revision.draft_revision_id' \
  db/approval-request-model-assembler.ts

printf '\n=== COMPLETE CLIENT HANDOFF ===\n'
python3 <<'PY'
from pathlib import Path

api = Path("client/src/approvals/approvalRequestApi.ts")
s = api.read_text()

old = '''  lineage_id: string;
  draft_package_id: string;
  executive_question: string;
'''
new = '''  lineage_id: string;
  draft_package_id: string;
  draft_revision_id: string;
  executive_question: string;
'''

if old not in s:
    raise SystemExit("Approval Request type anchor changed")

s = s.replace(old, new, 1)

old = '''export async function approveCanonicalPackage(
  draftPackageId: string,
): Promise<CanonicalPackageApprovalResult> {
  const normalizedDraftPackageId = requireText(
    draftPackageId,
    "draftPackageId",
  );

  const response = await fetch(
    "/api/matilda/canonical-package",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        draft_package_id: normalizedDraftPackageId,
      }),
    },
  );
'''

new = '''export async function approveCanonicalPackage(
  draftPackageId: string,
  draftRevisionId: string,
): Promise<CanonicalPackageApprovalResult> {
  const normalizedDraftPackageId = requireText(
    draftPackageId,
    "draftPackageId",
  );
  const normalizedDraftRevisionId = requireText(
    draftRevisionId,
    "draftRevisionId",
  );

  const response = await fetch(
    "/api/matilda/canonical-package",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        draft_package_id: normalizedDraftPackageId,
        draft_revision_id: normalizedDraftRevisionId,
      }),
    },
  );
'''

if old not in s:
    raise SystemExit("approveCanonicalPackage anchor changed")

s = s.replace(old, new, 1)
api.write_text(s)

workspace = Path("client/src/approvals/ApprovalsWorkspace.tsx")
s = workspace.read_text()

old = '''        await approveCanonicalPackage(
          request.draft_package_id,
        );
'''
new = '''        await approveCanonicalPackage(
          request.draft_package_id,
          request.draft_revision_id,
        );
'''

if old not in s:
    raise SystemExit("ApprovalsWorkspace approve anchor changed")

s = s.replace(old, new, 1)
workspace.write_text(s)
PY

printf '\n=== VERIFY NARROW IMPLEMENTATION ===\n'
git diff --check

grep -q 'draft_revision_id: string;' \
  client/src/approvals/approvalRequestApi.ts
grep -q 'draft_revision_id: normalizedDraftRevisionId' \
  client/src/approvals/approvalRequestApi.ts
grep -q 'request.draft_revision_id' \
  client/src/approvals/ApprovalsWorkspace.tsx

git diff -- \
  db/approval-request-model-assembler.ts \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== VERIFY PROTECTED BOUNDARIES ===\n'
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

printf '\n=== FINAL IMPLEMENTATION STATE ===\n'
echo "DRAFT_REVISION_APPROVAL_HANDOFF_IMPLEMENTED=YES"
echo "REVIEW_REVISION_EXPOSED=YES"
echo "EXACT_DRAFT_REVISION_ID_SUBMITTED_ON_APPROVE=YES"
echo "CANONICAL_BOUNDARY_CHANGED=NO"
echo "DELEGATION_CHANGED=NO"
echo "VALIDATION_CHANGED=NO"
echo "ENVELOPE_CHANGED=NO"
echo "EXECUTION_CHANGED=NO"
echo "GOVERNANCE_CHANGED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=RUNTIME_VALIDATE_APPROVAL_REVIEW_AND_APPROVE_HANDOFF"
echo "CLEAR_STOPPING_POINT=YES"
