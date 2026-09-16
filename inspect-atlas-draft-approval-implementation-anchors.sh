#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS DRAFT / APPROVAL ADAPTER — AUTHORIZED IMPLEMENTATION ANCHORS ====="
echo "MODE=AUTHORIZED_IMPLEMENTATION_PRECONDITION_INSPECTION"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "AUTHORIZED_UNIT=MINIMUM_ATLAS_LIVING_DRAFT_AND_PENDING_APPROVAL_READ_ONLY_OBSERVATION_ADAPTER"
echo "CHECKPOINT=$(git rev-parse HEAD)"

echo
echo "===== EXISTING ATLAS PRE-EXECUTION ADAPTER ====="
sed -n '1,320p' server/atlas/atlas-preexecution-read-model.ts

echo
echo "===== PACKAGE READ REPOSITORY — EXACT EXPORTS / TYPES ====="
grep -nE -B20 -A100 \
  'export (type|interface|function|const)|createPackageReadRepository|listLivingDraftPackagesByProject|getLivingDraftPackageById' \
  db/package-read-repository.ts || true

echo
echo "===== APPROVAL REPOSITORY — EXACT EXPORTS / TYPES ====="
grep -nE -B20 -A110 \
  'export (type|interface|function|const)|createApprovalRequestRepository|listPendingCanonicalPackageApprovalsByProject|getPendingCanonicalPackageApprovalById|getPendingCanonicalPackageApprovalByDraftPackageId' \
  db/approval-request-repository.ts || true

echo
echo "===== PACKAGE ASSEMBLER — EXACT RETURN SHAPE ====="
grep -nE -B20 -A110 \
  'export (type|interface|function|const)|LivingDraft|PackageRead|assemble|conversation|lineage|project' \
  db/package-read-model-assembler.ts || true

echo
echo "===== APPROVAL ASSEMBLER — EXACT RETURN SHAPE ====="
grep -nE -B20 -A110 \
  'export (type|interface|function|const)|Approval|Pending|assemble|conversation|lineage|project' \
  db/approval-request-model-assembler.ts || true

echo
echo "===== EXISTING TEST PATTERNS ====="
grep -RniE -B15 -A80 \
  'listLivingDraftPackagesByProject|getLivingDraftPackageById|listPendingCanonicalPackageApprovalsByProject|getPendingCanonicalPackageApprovalById' \
  db server \
  --include='*.test.ts' \
  2>/dev/null | head -n 1400 || true

echo
echo "===== IMPLEMENTATION CONTRACT ====="
echo "OBSERVATION_1=LIVING_DRAFT"
echo "OBSERVATION_1_AUTHORITY=NON_AUTHORITATIVE"
echo "OBSERVATION_2=PENDING_APPROVAL_REQUEST"
echo "OBSERVATION_2_AUTHORITY=PENDING_TRANSITION_NOT_AUTHORITATIVE"
echo "PROJECT_SCOPE=REQUIRED"
echo "CONVERSATION_IDENTITY=PRESERVE"
echo "LINEAGE_IDENTITY=PRESERVE"
echo "NEW_PERSISTENCE=NO"
echo "SOURCE_MUTATION=NO"
echo "MATILDA_WORKFLOW_CHANGE=NO"
echo "APPROVAL_TRANSITION_CHANGE=NO"
echo "ATLAS_REASONER_WIRING=NO"
echo "EXECUTION_EVENT_COERCION=NO"
echo "UNSCOPED_APPROVAL_API_USE=FORBIDDEN"

echo
echo "===== ATTEMPT STATE ====="
echo "IMPLEMENTATION_ATTEMPT_STARTED=NO"
echo "FAILED_IMPLEMENTATION_ATTEMPTS=0"
echo "NEXT_ACTION=CONSTRUCT_ATTEMPT_1_FROM_THE_EXACT_VERIFIED_TYPES_AND_SIGNATURES_ONLY"

echo
echo "===== WORKTREE ====="
git status --short
