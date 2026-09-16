#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="254c1c97d"

git fetch origin "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS PRE-EXECUTION — TYPED READ MODEL ADAPTER BOUNDARY ====="
echo "MODE=READ_ONLY_COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "===== ESTABLISHED CONTRACT ====="
echo "CONTRACT=ATLAS_NON_AUTHORITATIVE_PREEXECUTION_OBSERVATION"
echo "ATLAS_ROLE=READ_OBSERVE_DERIVE"
echo "PREEXECUTION_AS_EXECUTION_EVENT=PROHIBITED"
echo "SOURCE_MUTATION=PROHIBITED"
echo "SOURCE_AUTHORSHIP=PRESERVE"
echo "AUTHORITY_STATE=PRESERVE"
echo "IDENTITY_AND_LINEAGE=PRESERVE"

echo
echo "===== FIND CURRENT ATLAS INPUT TYPES AND ENTRY POINTS ====="
grep -R -n -E \
  'ExecutionEvent|analyze.*Atlas|Atlas.*analy|reconstruct.*Atlas|atlas.*event|events:.*ExecutionEvent|executionEvents' \
  server routes db scripts \
  --include='*.ts' \
  2>/dev/null | head -n 1000 || true

echo
echo "===== FIND CURRENT ATLAS READ / REPOSITORY BOUNDARIES ====="
grep -R -n -E \
  'create.*Repository|readonly: true|fileMustExist|list.*Execution|get.*Execution|execution.*repository|atlas.*repository' \
  server routes db scripts \
  --include='*.ts' \
  2>/dev/null | head -n 1000 || true

echo
echo "===== EXISTING PRE-EXECUTION READ MODELS ====="
sed -n '1,180p' db/package-read-repository.ts 2>/dev/null || true

grep -n -B20 -A80 \
  -E 'export function listInterpretationEvidenceLedgerEntries|export function readInterpretationEvidenceLedgerEntriesByIds' \
  db/matilda-interpretation-runtime.ts 2>/dev/null || true

echo
echo "===== CURRENT ATLAS TYPES ====="
grep -R -n -B30 -A120 \
  -E 'type ExecutionEvent|interface ExecutionEvent|export type ExecutionEvent|export interface ExecutionEvent' \
  server routes db scripts \
  --include='*.ts' \
  2>/dev/null | head -n 900 || true

echo
echo "===== CURRENT ATLAS CALL SITES ====="
grep -R -n -B30 -A100 \
  -E 'reconstructWhy|reconstruct.*Atlas|analyze.*events|ExecutionEvent\[\]' \
  server routes \
  --include='*.ts' \
  2>/dev/null | head -n 1200 || true

echo
echo "===== ADAPTER QUESTIONS ====="
echo "Q1=WHERE_IS_THE_NARROWEST_READ_ONLY_ATLAS_INPUT_SEAM"
echo "Q2=CAN_EXISTING_IEL_AND_PACKAGE_READERS_BE_REUSED_WITHOUT_WRITE_PATH_CHANGES"
echo "Q3=IS_A_NEW_TYPED_ATLAS_PREEXECUTION_OBSERVATION_REQUIRED"
echo "Q4=WHAT_EXACT_DISCRIMINATED_SOURCE_TYPES_ARE_REQUIRED"
echo "Q5=WHERE_SHOULD_AUTHORITY_STATE_BE_PROJECTED_WITHOUT_REINTERPRETATION"
echo "Q6=HOW_SHOULD_IEL_DRAFT_AND_CANONICAL_LINEAGE_BE_JOINED"
echo "Q7=CAN_THE_ADAPTER_REMAIN_PROJECT_SCOPED_AND_READ_ONLY"
echo "Q8=DOES_CURRENT_ATLAS_REASONING_ACCEPT_MULTIPLE_INPUT_TYPES"
echo "Q9=IF_NOT_WHAT_IS_THE_SMALLEST_NON_SEMANTIC_INTEGRATION_SEAM"
echo "Q10=WHAT_EXACT_FILES_WOULD_CHANGE_IN_A_MINIMUM_IMPLEMENTATION"

echo
echo "===== REQUIRED OUTPUT ====="
echo "OUTPUT_1=EXACT_EXISTING_ATLAS_INPUT_BOUNDARY"
echo "OUTPUT_2=EXACT_EXISTING_PREEXECUTION_READERS"
echo "OUTPUT_3=MINIMUM_TYPED_OBSERVATION_SHAPE"
echo "OUTPUT_4=MINIMUM_ADAPTER_LOCATION"
echo "OUTPUT_5=MINIMUM_REASONER_INTEGRATION_BOUNDARY"
echo "OUTPUT_6=EXACT_PROPOSED_FILE_SCOPE"
echo "OUTPUT_7=REGRESSION_SURFACE"
echo "OUTPUT_8=IMPLEMENTATION_READINESS_CLASSIFICATION"

echo
echo "===== STOP BOUNDARY ====="
echo "IMPLEMENTATION=NO"
echo "SOURCE_CHANGE=NO"
echo "DATABASE_CHANGE=NO"
echo "DOGFOOD_CLEANUP=FROZEN"
echo "NEXT_ACTION=CLASSIFY_MINIMUM_TYPED_READ_MODEL_ADAPTER_AND_INTEGRATION_SEAM_FROM_REPOSITORY_EVIDENCE"

echo
echo "===== WORKTREE ====="
git status --short
