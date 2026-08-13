#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 CORRIDOR 1 — PRODUCTION STABILITY CONTRACT RECONCILIATION ==="

echo
echo "=== REPOSITORY BASELINE ==="
echo "REPOSITORY=$(basename "$(git rev-parse --show-toplevel)")"
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "SUBJECT=$(git log -1 --pretty=%s)"
echo "WORKTREE_STATUS_BEGIN"
git status --short
echo "WORKTREE_STATUS_END"

echo
echo "=== EXPECTED BASELINE ==="
test "$(basename "$(git rev-parse --show-toplevel)")" = "motherboard-systems-hq-clean"
test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test "$(git rev-parse --short=8 HEAD)" = "d8256e8d"
test "$(git log -1 --pretty=%s)" = "Reconcile canonical Phase 3 starting boundary"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor d8256e8d origin/feature/support-source-references-runtime
echo "REPOSITORY_VERIFIED=YES"
echo "BRANCH_VERIFIED=YES"
echo "HEAD_VERIFIED=YES"
echo "WORKTREE_CLEAN=YES"
echo "ORIGIN_CONTAINS_EXPECTED_HEAD=YES"

echo
echo "=== GOVERNING PHASE CHECKPOINTS ==="
git merge-base --is-ancestor c2cd5fb5 HEAD
git merge-base --is-ancestor 08d9d38d HEAD
echo "PHASE_1_CLOSURE_ANCESTRY=CONFIRMED"
echo "PHASE_2_CLOSURE_ANCESTRY=CONFIRMED"
echo "LATEST_REPORTED_DR=20260812_155502"
echo "LATEST_REPORTED_DR_PROTECTS=08d9d38d"
echo "CURRENT_HEAD_LATER_DR_PROTECTION=NOT_ESTABLISHED_BY_REPOSITORY_HISTORY"

echo
echo "=== PHASE 3 CANONICAL ARTIFACT INVENTORY ==="
artifacts=(
  "scripts/classify-phase-3-production-stability-validation-starting-boundary.sh"
  "scripts/define-phase-3-production-stability-validation-contract.sh"
  "scripts/classify-phase-3-repeated-unseeded-validation-fixture-and-runner.sh"
  "scripts/run-phase-3-repeated-unseeded-production-stability-validation.sh"
  "scripts/classify-phase-3-repeated-unseeded-validation-result.sh"
  "scripts/classify-phase-3-fail-closed-contract-preservation.sh"
  "scripts/classify-phase-3-single-ollama-invocation-preservation.sh"
  "scripts/classify-phase-3-production-regression-validation-boundary.sh"
  "scripts/classify-phase-3-existing-regression-validation-set.sh"
  "scripts/classify-phase-3-existing-regression-validation-result.sh"
  "scripts/classify-phase-3-generation-stability-closure-readiness.sh"
)

for artifact in "${artifacts[@]}"; do
  if [[ -f "$artifact" ]]; then
    echo "PRESENT=$artifact"
  else
    echo "MISSING=$artifact"
  fi
done

echo
echo "=== CORRIDOR 1 CONTRACT EVIDENCE ==="
contract="scripts/define-phase-3-production-stability-validation-contract.sh"

if [[ ! -f "$contract" ]]; then
  echo "CORRIDOR_1_CONTRACT_ARTIFACT=ABSENT"
  echo "CORRIDOR_1_RECONCILIATION=BLOCKED"
  exit 1
fi

echo "CORRIDOR_1_CONTRACT_ARTIFACT=PRESENT"
grep -nEi \
  'unseed|seed|temperature|top_p|top_k|retr|model|fail.closed|accept|production|ollama|invocation|baseline|stability|semantic|fixture|fingerprint|failure|classification' \
  "$contract" || true

echo
echo "=== VALIDATION RUNNER EVIDENCE ==="
runner="scripts/run-phase-3-repeated-unseeded-production-stability-validation.sh"

if [[ -f "$runner" ]]; then
  grep -nEi \
    'validationGenerationSeed|seed|temperature|top_p|top_k|retr|model|ollama|invocation|unseed|accept|fail.closed|semantic|production' \
    "$runner" || true
else
  echo "PHASE_3_UNSEEDED_RUNNER=ABSENT"
fi

echo
echo "=== REPOSITORY-WIDE GENERATION CONTROL CHECK ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude='*.map' \
  'validationGenerationSeed|options\.seed|temperature|top_p|top_k' \
  app server scripts packages src 2>/dev/null || true

echo
echo "=== CORRIDOR 1 RECONCILIATION BOUNDARY ==="
echo "PRODUCTION_BASELINE_EXPECTED=UNCHANGED_UNCONFIGURED_UNSEEDED_GENERATION"
echo "VALIDATION_SEED_424242_PRODUCTION_PROMOTION=PROHIBITED"
echo "PRODUCTION_POLICY_CHANGE=NOT_AUTHORIZED"
echo "VALIDATOR_WEAKENING=PROHIBITED"
echo "MULTI_INVOCATION_RETRY_POLICY=NOT_AUTHORIZED"
echo "CORRIDOR_1_ACTIVITY=INVESTIGATION_AND_CONTRACT_RECONCILIATION_ONLY"
echo "NEXT_DECISION=CLASSIFY_EXISTING_PHASE_3_CONTRACT_AGAINST_CURRENT_ANCESTRY_AND_BASELINE"
