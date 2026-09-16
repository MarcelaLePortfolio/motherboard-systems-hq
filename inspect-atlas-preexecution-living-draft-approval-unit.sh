#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="a9e6ccf18"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS PRE-EXECUTION — LIVING DRAFT / APPROVAL BOUNDARY ====="
echo "MODE=READ_ONLY_INVESTIGATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PREVIOUS_UNIT=IEL_READ_ADAPTER_CLOSED"
echo "CHECKPOINT=$(git rev-parse HEAD)"

echo
echo "===== DISCOVER EXACT READ SURFACES ====="
find db server -type f -name '*.ts' -print0 |
  xargs -0 grep -nEi \
  'living.?draft|pending.?approval|approval.?request|canonical.?package|package.?approval|authority.?status|approval.?status' \
  2>/dev/null | head -n 1400 || true

echo
echo "===== LIVING DRAFT READERS ====="
grep -RniE -B20 -A80 \
  'get.*LivingDraft|read.*LivingDraft|list.*LivingDraft|SELECT.*living|FROM .*living.*draft|living_draft' \
  db server \
  --include='*.ts' \
  2>/dev/null | head -n 1200 || true

echo
echo "===== APPROVAL READERS ====="
grep -RniE -B20 -A90 \
  'get.*Approval|read.*Approval|list.*Approval|pending.*approval|approval_request|approval_status|approvalStatus' \
  db server \
  --include='*.ts' \
  2>/dev/null | head -n 1400 || true

echo
echo "===== CANONICAL PACKAGE READERS ====="
grep -RniE -B20 -A90 \
  'get.*Canonical.*Package|read.*Canonical.*Package|list.*Canonical.*Package|matilda_canonical_packages|canonical_package|canonicalPackage' \
  db server \
  --include='*.ts' \
  2>/dev/null | head -n 1400 || true

echo
echo "===== AUTHORITY TRANSITION SURFACES ====="
grep -RniE -B20 -A90 \
  'non-authoritative|non_authoritative|authoritative|approval.*transition|approve.*package|authority_status|authorityStatus' \
  db server \
  --include='*.ts' \
  2>/dev/null | head -n 1400 || true

echo
echo "===== EXISTING ATLAS PRE-EXECUTION CONTRACT ====="
sed -n '1,260p' server/atlas/atlas-preexecution-read-model.ts

echo
echo "===== CLASSIFICATION TARGET ====="
echo "Q1=EXACT_EXISTING_LIVING_DRAFT_READ_API"
echo "Q2=EXACT_EXISTING_PENDING_APPROVAL_READ_API"
echo "Q3=EXACT_EXISTING_CANONICAL_PACKAGE_READ_API_IF_ANY"
echo "Q4=AUTHORITY_STATE_AVAILABLE_FROM_EXISTING_READ_MODELS"
echo "Q5=IDENTITY_PROJECT_CONVERSATION_AND_LINEAGE_FIELDS_AVAILABLE"
echo "Q6=WHETHER_LIVING_DRAFT_AND_APPROVAL_CAN_BE_OBSERVED_WITHOUT_NEW_PERSISTENCE"
echo "Q7=MINIMUM_NEXT_ATLAS_READ_ONLY_ADAPTER_FILES"

echo
echo "===== ARCHITECTURAL INVARIANTS ====="
echo "LIVING_DRAFT_AUTHORITY=NON_AUTHORITATIVE"
echo "APPROVAL_IS_AUTHORITY_TRANSITION=YES"
echo "CANONICAL_PACKAGE_AUTHORITY=AUTHORITATIVE_ONLY_AFTER_APPROVAL"
echo "ATLAS_OBSERVATION_MUST_NOT_CREATE_AUTHORITY=YES"
echo "ATLAS_OBSERVATION_MUST_NOT_MUTATE_SOURCE_STATE=YES"
echo "ATLAS_EXECUTION_EVENT_COERCION=FORBIDDEN"

echo
echo "===== STOP BOUNDARY ====="
echo "SOURCE_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "MATILDA_CHANGE=NONE"
echo "ATLAS_REASONER_WIRING=NONE"
echo "IMPLEMENTATION=NONE"
echo "STAGING=NONE"
echo "COMMIT=NONE"
echo "PUSH=NONE"
echo "DOGFOOD_CLEANUP=FROZEN"
echo "NEXT_ACTION=CLASSIFY_EVIDENCE_AND_DEFINE_MINIMUM_LIVING_DRAFT_APPROVAL_OBSERVATION_UNIT"

echo
echo "===== WORKTREE ====="
git status --short
