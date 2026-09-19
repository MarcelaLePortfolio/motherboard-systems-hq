#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="47a65a234"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== AUTHORIZED IMPLEMENTATION BOUNDARY ===\n'
echo "DRAFT_REVISION_APPROVAL_HANDOFF_AUTHORIZED=YES"
echo "CREATE_OR_REUSE_REVIEW_REVISION=YES"
echo "EXPOSE_EXACT_DRAFT_REVISION_ID=YES"
echo "APPROVE_SUBMITS_EXACT_DRAFT_REVISION_ID=YES"
echo "CANONICAL_BOUNDARY_CHANGE_AUTHORIZED=NO"
echo "DELEGATION_CHANGE_AUTHORIZED=NO"
echo "VALIDATION_CHANGE_AUTHORIZED=NO"
echo "ENVELOPE_CHANGE_AUTHORIZED=NO"
echo "EXECUTION_CHANGE_AUTHORIZED=NO"
echo "GOVERNANCE_CHANGE_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE_AUTHORIZED=NO"

python3 <<'PY'
from pathlib import Path

p = Path("db/approval-request-model-assembler.ts")
s = p.read_text()

old = '''import {
  assembleReconciledInterpretationSummary,
} from "./matilda-reconciled-intent-runtime";
'''

new = '''import {
  assembleReconciledInterpretationSummary,
} from "./matilda-reconciled-intent-runtime";
import {
  createDraftRevisionForApprovalReview,
} from "./matilda-draft-revision-runtime";
'''

if old not in s:
    raise SystemExit("Expected assembler import anchor not found")

s = s.replace(old, new, 1)

old = '''  draft_package_id: string;
  executive_question: string;
'''

new = '''  draft_package_id: string;
  draft_revision_id: string;
  executive_question: string;
'''

if old not in s:
    raise SystemExit("Expected read-model interface anchor not found")

s = s.replace(old, new, 1)

old = '''  const summary = assembleReconciledInterpretationSummary({
'''

new = '''  const revision = createDraftRevisionForApprovalReview({
    draft_package_id: draftPackageId,
  });

  const summary = assembleReconciledInterpretationSummary({
'''

if old not in s:
    raise SystemExit("Expected assembler function anchor not found")

s = s.replace(old, new, 1)

old = '''    draft_package_id: summary.draft_package_id,
    executive_question:
'''

new = '''    draft_package_id: summary.draft_package_id,
    draft_revision_id: revision.draft_revision_id,
    executive_question:
'''

if old not in s:
    raise SystemExit("Expected assembler return anchor not found")

s = s.replace(old, new, 1)
p.write_text(s)

p = Path("client/src/approvals/approvalRequestApi.ts")
s = p.read_text()

old = '''export async function approveCanonicalPackage(
  draftPackageId: string,
): Promise<CanonicalPackageApprovalResult> {
  const normalizedDraftPackageId = requireText(
    draftPackageId,
    "draftPackageId",
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
'''

if old not in s:
    raise SystemExit("Expected approval API function anchor not found")

s = s.replace(old, new, 1)

old = '''        body: JSON.stringify({
          draft_package_id: normalizedDraftPackageId,
        }),
'''

new = '''        body: JSON.stringify({
          draft_package_id: normalizedDraftPackageId,
          draft_revision_id: normalizedDraftRevisionId,
        }),
'''

if old not in s:
    raise SystemExit("Expected approval API body anchor not found")

s = s.replace(old, new, 1)
p.write_text(s)

p = Path("client/src/approvals/ApprovalsWorkspace.tsx")
s = p.read_text()

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
    raise SystemExit("Expected ApprovalsWorkspace approve anchor not found")

s = s.replace(old, new, 1)
p.write_text(s)

# Add draft_revision_id to the client Approval Request type at the same
# semantic boundary as draft_package_id.
p = Path("client/src/approvals/approvalRequestApi.ts")
s = p.read_text()

needle = '''  draft_package_id: string;
'''

if needle not in s:
    raise SystemExit("Expected client Approval Request type anchor not found")

# Only add if not already present.
if "draft_revision_id: string;" not in s:
    s = s.replace(
        needle,
        '''  draft_package_id: string;
  draft_revision_id: string;
''',
        1,
    )

p.write_text(s)
PY

printf '\n=== VERIFY NARROW DIFF ===\n'
git diff --check
git diff -- \
  db/approval-request-model-assembler.ts \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/ApprovalsWorkspace.tsx

CHANGED="$(git diff --name-only -- \
  db/approval-request-model-assembler.ts \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/ApprovalsWorkspace.tsx)"

test -n "$CHANGED"

printf '\n=== VERIFY CANONICAL BOUNDARY UNCHANGED ===\n'
git diff --exit-code -- \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  db/matilda-draft-revision-runtime.ts

printf '\n=== RUN TARGETED TESTS ===\n'
npx tsx --test \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts

printf '\n=== BUILD SERVER ===\n'
npm run build

printf '\n=== BUILD CLIENT ===\n'
npm --prefix client run build

printf '\n=== VERIFY AUTHORITY BOUNDARY ===\n'
git diff --exit-code -- \
  server/execution \
  server/operational \
  db/governance-execution-approvals.ts \
  db/governance-execution-scopes.ts \
  db/governance-execution-reconciliation-persistence.ts

echo "DRAFT_REVISION_APPROVAL_HANDOFF_IMPLEMENTED=YES"
echo "CANONICAL_BOUNDARY_CHANGED=NO"
echo "DELEGATION_CHANGED=NO"
echo "VALIDATION_CHANGED=NO"
echo "ENVELOPE_CHANGED=NO"
echo "EXECUTION_CHANGED=NO"
echo "GOVERNANCE_CHANGED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=RUNTIME_VALIDATE_APPROVAL_REVIEW_AND_APPROVE_HANDOFF"

git add -- \
  db/approval-request-model-assembler.ts \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/ApprovalsWorkspace.tsx \
  implement-draft-revision-approval-handoff.sh

git commit -m "Wire Draft Revision through approval handoff"
git push origin "$BRANCH"
