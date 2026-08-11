#!/usr/bin/env bash
set -euo pipefail

echo "=== DEFINE BOUNDED INTERVENTION EXPERIMENT ACCEPTANCE CONTRACT ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY PHASE-1 CLOSURE CHECKPOINT ==="
expected_head="377a1d57"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Phase 1 closure checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/define-bounded-intervention-experiment-acceptance-contract\.sh$|^ M scripts/define-bounded-intervention-experiment-acceptance-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "PHASE_1_CLOSURE_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY INTERVENTION DECISION ==="
grep -nE \
  'BOUNDED_EXPERIMENT_DECISION=|JUSTIFIED|PRODUCTION_INTERVENTION_DECISION=|NOT_YET_AUTHORIZED|PHASE_1_RESULT=|PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION_COMPLETE|NEXT_PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY|NEXT_ACTION=DEFINE_BOUNDED_INTERVENTION_EXPERIMENT_ACCEPTANCE_CONTRACT' \
  scripts/classify-generation-stability-intervention-decision-boundary.sh

echo "INTERVENTION_DECISION=CONFIRMED"

echo
echo "=== VERIFY ESTABLISHED FAILURE BASELINE ==="
grep -nE \
  'Nine of ten|nine of ten|line 22|line 20|MODEL_RELIABILITY_AT_DUAL_PROJECT_CONTEXT_IDENTITY_BOUNDARY|CHILD_SEGMENT_IDENTITY_MISAUTHORED_AS_PARENT_SUPPORT_IDENTITY' \
  scripts/classify-structured-response-reliability-failure-surface.sh

echo "ESTABLISHED_FAILURE_BASELINE=CONFIRMED"

echo
echo "=== VERIFY EXISTING DIAGNOSTIC CONTROL SEAM ==="
grep -nE \
  'validationGenerationSeed|seed: context\.validationGenerationSeed' \
  scripts/utils/ollamaChat.ts

echo "DIAGNOSTIC_CONTROL_SEAM=CONFIRMED"

echo
echo "=== VERIFY SEEDED EVIDENCE BOUNDARY ==="
grep -nE \
  'All three seeded runs|No seeded run emitted the invalid child-derived :22 parent identity|Seeded reproducibility does not prove|production seed should not yet be implemented' \
  scripts/classify-adaptive-detail-stability-from-seeded-evidence.sh

echo "SEEDED_EVIDENCE_BOUNDARY=CONFIRMED"

echo
echo "=== BOUNDED INTERVENTION EXPERIMENT ACCEPTANCE CONTRACT ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=BOUNDED_INTERVENTION_EXPERIMENT_ACCEPTANCE_CONTRACT

GOVERNING_QUESTION=
  What evidence must a bounded diagnostic intervention produce before it may
  be considered a viable candidate for later production generation-policy
  evaluation?

ESTABLISHED_BASELINE=
  Ten identical ordinary unseeded invocations produced:

  - 1 accepted fixture-semantic result;
  - 9 deterministic fail-closed results;
  - the same invalid child-derived line-22 parent support identity in all
    9 rejected runs.

BASELINE_ACCEPTANCE_RATE=
  1_OF_10

BASELINE_FAILURE_RATE=
  9_OF_10

KNOWN_FAILURE_SIGNATURE=
  A project_context_excerpt support reference uses child Segment identity
  line 22 instead of the supplied parent Source identity line 20.

EXPERIMENT_SCOPE=
  DIAGNOSTIC_ONLY

  No experiment performed under this contract changes production generation
  policy.

FIRST_CANDIDATE_CLASS=
  EXISTING_REQUEST_SCOPED_VALIDATION_SEED

RATIONALE=
  The validation-only seed is the narrowest already implemented diagnostic
  generation-control seam.

  Prior evidence shows reproducible accepted behavior under a fixed seed while
  leaving production generation behavior unchanged.

FIRST_CANDIDATE_PURPOSE=
  Determine whether the known acceptance-boundary failure remains absent across
  a bounded repeated sample under one fixed diagnostic sampling state.

FIXTURE=
  Reuse the established Adaptive Detail mixed-content live fixture that exposed
  the parent-versus-child support-identity failure.

FIXTURE_IMMUTABILITY=
  The user message, supplied parent Source identity, supplied child Segment
  identities, project context, schema, prompt, deterministic validator, and
  semantic acceptance assertions must remain unchanged for the first candidate
  experiment.

CANDIDATE_VARIABLE=
  validationGenerationSeed only.

PROHIBITED_CONCURRENT_VARIABLES=
  - temperature;
  - top_p;
  - top_k;
  - model change;
  - prompt rewrite;
  - identity-presentation rewrite;
  - retry;
  - second model invocation;
  - schema relaxation;
  - validator relaxation;
  - semantic-history change.

SAMPLE_BOUNDARY=
  Execute exactly 10 sequential identical fixture invocations using one fixed
  validationGenerationSeed.

WHY_TEN=
  Ten runs match the established ordinary-unseeded baseline sample size and
  permit direct bounded comparison.

  Ten runs do not establish universal or long-run production reliability.

PER_RUN_OBSERVATIONS=
  1. invocation exit status;
  2. structured-response acceptance;
  3. fixture-semantic acceptance;
  4. supportSourceReferences;
  5. selectedContextSegments;
  6. explanationStatus;
  7. investigationLifecycle validity;
  8. reply presence;
  9. durableInterpretation presence;
  10. exact-output fingerprint.

PRIMARY_CANDIDATE_ACCEPTANCE_CRITERION=
  10_OF_10_FIXTURE_SEMANTIC_PASS

KNOWN_FAILURE_ACCEPTANCE_CRITERION=
  0_OF_10_CHILD_DERIVED_LINE_22_PARENT_SUPPORT_IDENTITIES

FAIL_CLOSED_ACCEPTANCE_CRITERION=
  0_OF_10_FAIL_CLOSED_OR_RUNTIME_REJECTIONS

STRUCTURAL_REGRESSION_ACCEPTANCE_CRITERION=
  0_OF_10_STRUCTURED_RESPONSE_CONTRACT_FAILURES

SEMANTIC_PRESERVATION_CRITERION=
  Every accepted run must continue to satisfy the independently established
  Adaptive Detail mixed-content semantic assertions.

EXACT_OUTPUT_REQUIREMENT=
  NOT_REQUIRED_FOR_SEMANTIC_ACCEPTANCE

  Exact repeatability may be measured as diagnostic evidence, but candidate
  acceptance depends on established structural and semantic boundaries rather
  than identical prose.

CANDIDATE_CLASSIFICATION_IF_ALL_CRITERIA_PASS=
  DIAGNOSTIC_CANDIDATE_SUPPORTED

  This classification means only that the candidate materially improves the
  bounded known failure surface under controlled conditions.

  It does not authorize production promotion.

CANDIDATE_CLASSIFICATION_IF_ANY_CRITERION_FAILS=
  DIAGNOSTIC_CANDIDATE_NOT_ESTABLISHED

  Preserve failing artifacts and classify the failure before considering any
  additional control.

PRODUCTION_PROMOTION_REQUIREMENTS=
  Even a 10-of-10 passing diagnostic sample must not become production policy
  without separate evidence addressing:

  - behavior across wider structured-response responsibilities;
  - semantic-quality preservation;
  - production ownership and configuration boundary;
  - deterministic validation compatibility;
  - rollback;
  - ordinary production acceptance expectations;
  - explicit implementation authorization.

SECOND_CANDIDATE_BOUNDARY=
  Identity-presentation intervention remains a separate candidate class.

  Do not combine it with the fixed-seed experiment.

  Consider it only after the first candidate is classified, preserving causal
  isolation.

TEMPERATURE_TOP_P_TOP_K_BOUNDARY=
  Do not experiment with these controls yet.

  They remain broader sampling-policy candidates and require a separately
  justified experiment if narrower candidates do not resolve the decision.

MODEL_CHANGE_BOUNDARY=
  DEFERRED

RETRY_BOUNDARY=
  NOT_AUTHORIZED

MULTI_INVOCATION_BOUNDARY=
  NOT_AUTHORIZED

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

IMPLEMENTATION_AUTHORIZED=
  DIAGNOSTIC_EXPERIMENT_ONLY

PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_CHANGE=NONE

CORRIDOR_RESULT=
  BOUNDED_INTERVENTION_EXPERIMENT_ACCEPTANCE_CONTRACT_DEFINED

NEXT_ACTION=
  CLASSIFY_FIXED_SEED_DIAGNOSTIC_EXPERIMENT_FIXTURE_AND_RUNNER
MAP

echo
echo "=== VERIFY CONTRACT-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/define-bounded-intervention-experiment-acceptance-contract\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside contract-definition scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CONTRACT_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/define-bounded-intervention-experiment-acceptance-contract.sh
git diff --cached --check
git commit -m "Define bounded intervention experiment acceptance contract"
git push
