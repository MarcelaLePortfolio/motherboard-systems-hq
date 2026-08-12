#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY FAILURE CHARACTERIZATION OBSERVED CLASSES ==="

expected_head="a0a557a7"

[[ "$(git rev-parse --short=8 HEAD)" == "$expected_head" ]] || {
  echo "STOP: HEAD no longer matches expected baseline $expected_head."
  exit 2
}

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-failure-characterization-observed-classes\.sh$|^ M scripts/classify-failure-characterization-observed-classes\.sh$' ||
  true
)"

[[ -z "$unexpected" ]] || {
  echo "STOP: unexpected working-tree changes:"
  printf '%s\n' "$unexpected"
  exit 2
}

grep -q 'TOTAL_RUNS=10' scripts/close-conversation-engine-generation-stability-milestone.sh
grep -q 'FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=8' scripts/close-conversation-engine-generation-stability-milestone.sh
grep -q 'FIXTURE_SEMANTIC_FAILURE_RUNS=2' scripts/close-conversation-engine-generation-stability-milestone.sh
grep -q 'UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE' scripts/classify-phase-3-repeated-unseeded-validation-result.sh

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR_MAP=USER_GOVERNED_AND_FIXED
CORRIDOR=FAILURE_CHARACTERIZATION
GENERATION_VARIANCE_CORRIDOR=COMPLETE
GENERATION_VARIANCE_DR=20260811_180840

OBSERVED_SAMPLE=
TOTAL_RUNS=10
FIXTURE_SEMANTIC_PASS_RUNS=0
FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=8
FIXTURE_SEMANTIC_FAILURE_RUNS=2
UNIQUE_EXACT_OUTPUT_FINGERPRINTS=3

OBSERVED_FAILURE_CLASS_1=
INVALID_MODEL_AUTHORED_PROJECT_CONTEXT_SUPPORT_PROVENANCE
COUNT=8_OF_10
BOUNDARY=DETERMINISTIC_FAIL_CLOSED_VALIDATION
PRIMARY_SIGNATURE=UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE

OBSERVED_FAILURE_CLASS_2=
SEMANTIC_ACCEPTANCE_FAILURE_AFTER_SUCCESSFUL_ADAPTER_RETURN
COUNT=2_OF_10
BOUNDARY=ESTABLISHED_ADAPTIVE_DETAIL_SEMANTIC_ACCEPTANCE_SURFACE

FULL_SEMANTIC_SUCCESS=0_OF_10
FAIL_CLOSED_CONTRACT=PRESERVED
VALIDATOR_MALFUNCTION=NOT_ESTABLISHED
PRODUCTION_RUNTIME_REGRESSION=NOT_ESTABLISHED
ONE_OLLAMA_INVOCATION=PRESERVED

FAILURE_CHARACTERIZATION_CURRENT_DETERMINATION=
TWO_OBSERVED_FAILURE_CLASSES_ESTABLISHED

IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_CHANGE=NONE
CORRIDOR_CLOSURE=NO
FAILURE_CHARACTERIZATION_CORRIDOR=ACTIVE
NEXT_ACTION=CHARACTERIZE_FAILURE_REPEATABILITY_AND_CAUSAL_BOUNDARY
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-failure-characterization-observed-classes\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside Failure Characterization scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
