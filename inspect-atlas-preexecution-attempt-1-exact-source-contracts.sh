#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="d628b989f"

git fetch origin "$BRANCH"

echo "===== ATLAS PRE-EXECUTION — ATTEMPT 1 SOURCE CONTRACT INSPECTION ====="
echo "MODE=READ_ONLY_PREIMPLEMENTATION"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_STARTED=NO"
echo "FAILED_IMPLEMENTATION_ATTEMPTS=0"

test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo
echo "===== INTERPRETATION LEDGER CONTRACT ====="
grep -n -B35 -A220 \
  -E 'export (type|interface|function)|InterpretationEvidence|listInterpretationEvidenceLedgerEntries|readInterpretationEvidenceLedgerEntriesByIds' \
  db/matilda-interpretation-runtime.ts | head -n 1400 || true

echo
echo "===== LIVING DRAFT READ CONTRACT ====="
sed -n '1,280p' db/package-read-repository.ts

echo
echo "===== APPROVAL READ CONTRACT ====="
sed -n '1,260p' db/approval-request-repository.ts

echo
echo "===== CANONICAL PACKAGE CONTRACT ====="
grep -n -B30 -A180 \
  -E 'matilda_canonical_packages|package_id|package_version|draft_package_id|draft_revision_id|lineage_id|approved_interpretation|approval_timestamp|canonical_approved' \
  db/matilda-canonical-package-runtime.ts | head -n 1400 || true

echo
echo "===== READ-ONLY DATABASE CONVENTIONS ====="
grep -R -n -B20 -A100 \
  -E 'readonly: true|fileMustExist: true' \
  db server \
  --include='*.ts' | head -n 1200 || true

echo
echo "===== ATLAS TEST CONVENTIONS ====="
find server/atlas -maxdepth 1 -type f \
  \( -name '*.test.ts' -o -name '*.integration.test.ts' \) \
  -print |
  sort |
  while read -r FILE; do
    echo
    echo "----- $FILE -----"
    sed -n '1,260p' "$FILE"
  done

echo
echo "===== ATTEMPT 1 BOUNDARY ====="
echo "FILE_1=server/atlas/atlas-preexecution-observation.ts"
echo "FILE_2=server/atlas/atlas-preexecution-read-adapter.ts"
echo "FILE_3=server/atlas/atlas-preexecution-read-adapter.test.ts"
echo "READ_ONLY=YES"
echo "DATABASE_SCHEMA_CHANGE=NO"
echo "SOURCE_WRITE_PATH_CHANGE=NO"
echo "MATILDA_WORKFLOW_CHANGE=NO"
echo "EXECUTION_EVENT_CHANGE=NO"
echo "ATLAS_REASONER_WIRING=NO"
echo "PREEXECUTION_CAST_TO_EXECUTION_EVENT=NO"
echo "NEXT_ACTION=CONSTRUCT_ATTEMPT_1_FROM_VERIFIED_CONTRACTS_ONLY"

echo
echo "===== WORKTREE ====="
git status --short
