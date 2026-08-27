#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VERIFY PATENT-READINESS PROTOCOL AND RESUME CADE GIT WORK ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="40417557e"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== VERIFY PATENT-READINESS PROTOCOL EXISTS ==="
test -f docs/governance/PATENT_READINESS_DEVELOPMENT_PROTOCOL.md
git diff --exit-code HEAD^ HEAD -- docs/governance/PATENT_READINESS_DEVELOPMENT_PROTOCOL.md >/dev/null || true

echo
echo "=== VERIFY CURRENT REPOSITORY VISIBILITY / REMOTE CONTEXT ==="
git remote -v
git branch --show-current
git rev-parse HEAD

echo
echo "=== VERIFY PRIOR FAILED CONTRACT IMPLEMENTATION DID NOT MUTATE RUNTIME ==="
git diff 42b9d3fb0..40417557e -- \
  server/contracts/execution-envelope.v1.mjs \
  server/execution/build-execution-envelope-draft.mjs \
  server/execution/build-approval-artifact.mjs \
  server/execution/execution-approval-gate.mjs \
  server/guards/validate-execution-envelope.mjs \
  server/execution/governance-validator.mjs \
  server/cade/cade-executor.ts \
  scripts/agents_full/cade.ts

echo
echo "=== VERIFY FAILED ATTEMPT REMAINS EVIDENCE ONLY ==="
git show --stat --oneline 4282ade62
git show --name-only --format='' 4282ade62

echo
echo "=== PATENT-READINESS DEVELOPMENT BOUNDARY ==="
echo "PUBLICATION_IS_SEPARATE_FROM_ORDINARY_PUSH=YES"
echo "HUMAN_VS_AI_CONTRIBUTION_DISTINCTION_REQUIRED=YES"
echo "FAILED_ATTEMPT_HISTORY_PRESERVED=YES"
echo "TECHNICAL_VALIDATION_EVIDENCE_REQUIRED=YES"
echo "GIT_COMMITS_ARE_EVIDENCE_NOT_PATENTABILITY_DETERMINATIONS=YES"

echo
echo "=== CADE VERSION-CONTROL STATUS ==="
echo "CONTRACT_DESIGN=COMPLETE"
echo "CONTRACT_ONLY_IMPLEMENTATION_AUTHORIZED=YES"
echo "CONTRACT_ONLY_IMPLEMENTATION_COMPLETED=NO"
echo "LAST_IMPLEMENTATION_ATTEMPT=FAILED_BEFORE_RUNTIME_MUTATION"
echo "FAILED_HYPOTHESIS_COUNT_FOR_EXACT_ANCHOR_APPROACH=1"
echo "CURRENT_STABLE_HEAD=${CURRENT_HEAD}"
echo "NEXT_ACTION=INSPECT_EXACT_CURRENT_FILE_SHAPES_BEFORE_RETRYING_WITH_A_DIFFERENT_CLEAN_PATCH_METHOD"
