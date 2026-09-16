#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="a8919c507"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS PRE-EXECUTION — DRAFT / APPROVAL OBSERVATION CLASSIFICATION ====="
echo "MODE=READ_ONLY_CLASSIFICATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "CHECKPOINT=$(git rev-parse HEAD)"

echo
echo "===== EXACT LIVING DRAFT REPOSITORY ====="
sed -n '1,320p' db/package-read-repository.ts 2>/dev/null || true

echo
echo "===== EXACT LIVING DRAFT READ MODEL ====="
sed -n '1,320p' db/package-read-model-assembler.ts 2>/dev/null || true

echo
echo "===== EXACT APPROVAL REQUEST REPOSITORY ====="
sed -n '1,360p' db/approval-request-repository.ts 2>/dev/null || true

echo
echo "===== EXACT APPROVAL REQUEST READ MODEL ====="
sed -n '1,340p' db/approval-request-model-assembler.ts 2>/dev/null || true

echo
echo "===== CANONICAL PACKAGE READ SURFACE CANDIDATES ====="
grep -RniE -B12 -A70 \
  'export (async )?function (get|list|read|find).*([Cc]anonical|[Pp]ackage)|matilda_canonical_packages|canonical_package' \
  db server \
  --include='*.ts' \
  2>/dev/null | head -n 1600 || true

echo
echo "===== PROJECT / CONVERSATION / LINEAGE SCOPE ====="
grep -nEi -B8 -A35 \
  'project_id|conversation_id|lineage_id|WHERE|status|draft_non_authoritative|reconciliation_ready|canonical_package_created' \
  db/package-read-repository.ts \
  db/approval-request-repository.ts \
  db/package-read-model-assembler.ts \
  db/approval-request-model-assembler.ts \
  2>/dev/null || true

echo
echo "===== CLASSIFICATION TARGET ====="
echo "Q1=CONFIRM_EXACT_LIVING_DRAFT_READ_API"
echo "Q2=CONFIRM_EXACT_PENDING_APPROVAL_READ_API"
echo "Q3=CLASSIFY_CANONICAL_PACKAGE_READ_API_IF_PRESENT"
echo "Q4=CONFIRM_PROJECT_CONVERSATION_LINEAGE_SCOPE"
echo "Q5=CONFIRM_NO_NEW_PERSISTENCE_REQUIRED"
echo "Q6=DEFINE_MINIMUM_ATLAS_READ_ONLY_ADAPTER_BOUNDARY"

echo
echo "===== PRESERVED INVARIANTS ====="
echo "LIVING_DRAFT_AUTHORITY=NON_AUTHORITATIVE"
echo "APPROVAL_IS_AUTHORITY_TRANSITION=YES"
echo "ATLAS_OBSERVATION_MUST_NOT_CREATE_AUTHORITY=YES"
echo "ATLAS_OBSERVATION_MUST_NOT_MUTATE_SOURCE_STATE=YES"
echo "ATLAS_EXECUTION_EVENT_COERCION=FORBIDDEN"
echo "PARALLEL_ATLAS_PERSISTENCE=FORBIDDEN"

echo
echo "===== STOP BOUNDARY ====="
echo "SOURCE_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "MATILDA_CHANGE=NONE"
echo "ATLAS_REASONER_WIRING=NONE"
echo "IMPLEMENTATION=NONE"
echo "DOGFOOD_CLEANUP=FROZEN"
echo "NEXT_ACTION=CLASSIFY_OUTPUT_AND_DETERMINE_IMPLEMENTATION_GATE_FOR_MINIMUM_DRAFT_AND_PENDING_APPROVAL_OBSERVATION_ADAPTER"

echo
echo "===== WORKTREE ====="
git status --short
