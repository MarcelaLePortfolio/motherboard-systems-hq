#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="3d31b6de9"

git fetch origin "$BRANCH"

echo "===== ATLAS PRE-EXECUTION — IEL SOURCE SHAPE ====="
echo "MODE=READ_ONLY_PREIMPLEMENTATION"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_STARTED=NO"
echo "FAILED_IMPLEMENTATION_ATTEMPTS=0"

test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo
echo "===== IEL TYPE / ROW CONTRACT ====="
grep -n -B40 -A260 \
  -E 'InterpretationEvidenceLedger|InterpretationEvidence|interpretation_lifecycle_json|investigation_lifecycle_json|entry_id|project_id|conversation_id|created_at|durable_interpretation' \
  db/matilda-interpretation-runtime.ts | head -n 1800 || true

echo
echo "===== IEL LIST READER ====="
grep -n -B60 -A300 \
  -E 'export function listInterpretationEvidenceLedgerEntries|function listInterpretationEvidenceLedgerEntries' \
  db/matilda-interpretation-runtime.ts | head -n 1000 || true

echo
echo "===== IEL BY-ID READER ====="
grep -n -B60 -A260 \
  -E 'export function readInterpretationEvidenceLedgerEntriesByIds|function readInterpretationEvidenceLedgerEntriesByIds' \
  db/matilda-interpretation-runtime.ts | head -n 1000 || true

echo
echo "===== IEL TABLE CONTRACT ====="
grep -R -n -B40 -A220 \
  -E 'CREATE TABLE.*interpretation|interpretation_evidence|investigation_lifecycle_json|interpretation_lifecycle_json' \
  db \
  --include='*.ts' | head -n 1800 || true

echo
echo "===== ATTEMPT 1 SOURCE CLASSIFICATION ====="
echo "LIVING_DRAFT_READ_SURFACE=VERIFIED"
echo "PENDING_APPROVAL_READ_SURFACE=VERIFIED"
echo "CANONICAL_PACKAGE_PROVENANCE=VERIFIED"
echo "IEL_SOURCE_SHAPE=INSPECTED_BY_THIS_CHECKPOINT"
echo "READ_ONLY_ADAPTER_REQUIRED=YES"
echo "NEW_DATABASE_SCHEMA=NO"
echo "NEW_PRODUCER=NO"
echo "MATILDA_WORKFLOW_CHANGE=NO"
echo "ATLAS_REASONER_WIRING=NO"
echo "EXECUTION_EVENT_CHANGE=NO"
echo "NEXT_ACTION=CONSTRUCT_AUTHORIZED_ATTEMPT_1_TYPED_READ_MODEL_AND_ADAPTER_FROM_VERIFIED_SOURCE_SHAPES"

echo
echo "===== WORKTREE ====="
git status --short
