#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="c91756cc8"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS CANONICAL PACKAGE OBSERVATION — BOUNDARY INVESTIGATION ====="
echo "MODE=READ_ONLY_COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PREVIOUS_UNIT=LIVING_DRAFT_AND_PENDING_APPROVAL_OBSERVATION_ADAPTER_CLOSED"
echo "CHECKPOINT=$(git rev-parse HEAD)"

echo
echo "===== EXISTING CANONICAL PACKAGE READ SURFACES ====="
grep -RniE -B20 -A120 \
  'matilda_canonical_packages|canonical_approved|package_version|approval_timestamp|approval_actor|draft_revision_id|lineage_id' \
  db server \
  --include='*.ts' \
  2>/dev/null | head -n 2200 || true

echo
echo "===== POSSIBLE READ REPOSITORIES ====="
grep -RniE -B15 -A100 \
  'export (interface|type|function).*Canonical|create.*Canonical.*Repository|list.*Canonical|get.*Canonical|read.*Canonical' \
  db server \
  --include='*.ts' \
  2>/dev/null | head -n 1400 || true

echo
echo "===== OPERATIONAL PACKAGE AUTHORITY BOUNDARY ====="
sed -n '1,320p' db/operational-package-authority.ts 2>/dev/null || true

echo
echo "===== MISSION READ BOUNDARY ====="
sed -n '1,360p' db/mission-read-repository.ts 2>/dev/null || true

echo
echo "===== CURRENT ATLAS PRE-EXECUTION ADAPTERS ====="
sed -n '1,320p' server/atlas/atlas-preexecution-read-model.ts
sed -n '1,360p' server/atlas/atlas-draft-approval-observation.ts

echo
echo "===== CLASSIFICATION QUESTIONS ====="
echo "Q1=IS_THERE_AN_EXISTING_PROJECT_SCOPED_READ_ONLY_CANONICAL_PACKAGE_API"
echo "Q2=CAN_ATLAS_OBSERVE_CANONICAL_APPROVED_STATE_WITHOUT_USING_OPERATIONAL_SELECTION_AS_A_PROXY"
echo "Q3=WHICH_FIELDS_PRESERVE_PACKAGE_ID_VERSION_DRAFT_REVISION_LINEAGE_PROJECT_CONVERSATION_APPROVAL_ACTOR_AND_TIMESTAMP"
echo "Q4=CANONICAL_APPROVAL_AUTHORITY_MUST_REMAIN_DISTINCT_FROM_OPERATIONAL_PACKAGE_SELECTION"
echo "Q5=DOES_CANONICAL_OBSERVATION_REQUIRE_NEW_READ_REPOSITORY_OR_ONLY_AN_EXISTING_ONE"
echo "Q6=WHAT_IS_THE_MINIMUM_NEXT_ATLAS_ADAPTER_FILE_SCOPE"
echo "Q7=WHAT_REGRESSIONS_MUST_PROVE_DRAFT_PENDING_AND_CANONICAL_AUTHORITY_STATES_REMAIN_DISTINCT"

echo
echo "===== INVARIANTS ====="
echo "CANONICAL_PACKAGE_AUTHORITY=AUTHORITATIVE_AFTER_RECORDED_APPROVAL"
echo "OPERATIONAL_PACKAGE_SELECTION=SEPARATE_AUTHORITY_LAYER"
echo "ATLAS_MUST_NOT_INFER_OPERATIONAL_SELECTION_FROM_CANONICAL_APPROVAL=YES"
echo "ATLAS_MUST_NOT_CREATE_APPROVAL=YES"
echo "ATLAS_MUST_NOT_MUTATE_CANONICAL_STATE=YES"
echo "ATLAS_EXECUTION_EVENT_COERCION=FORBIDDEN"
echo "PARALLEL_ATLAS_PERSISTENCE=FORBIDDEN"

echo
echo "===== STOP BOUNDARY ====="
echo "SOURCE_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "MATILDA_CHANGE=NONE"
echo "GOVERNANCE_CHANGE=NONE"
echo "ATLAS_REASONER_WIRING=NONE"
echo "IMPLEMENTATION=NONE"
echo "DOGFOOD_CLEANUP=FROZEN"
echo "NEXT_ACTION=CLASSIFY_CANONICAL_PACKAGE_OBSERVATION_BOUNDARY_AND_REQUEST_SEPARATE_IMPLEMENTATION_AUTHORIZATION_IF_READY"

echo
echo "===== WORKTREE ====="
git status --short

git add inspect-atlas-canonical-package-observation-boundary.sh
git commit -m "Inspect Atlas canonical package observation boundary"
git push origin "$BRANCH"
