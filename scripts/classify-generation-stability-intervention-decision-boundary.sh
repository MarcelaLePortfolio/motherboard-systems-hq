#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY GENERATION STABILITY INTERVENTION DECISION BOUNDARY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY CORRIDOR-4 CHECKPOINT ==="
expected_head="295ca876"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Corridor 4 checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-generation-stability-intervention-decision-boundary\.sh$|^ M scripts/classify-generation-stability-intervention-decision-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CORRIDOR_4_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CHARACTERIZATION EVIDENCE ==="
grep -nE \
  'MODEL_RELIABILITY_AT_DUAL_PROJECT_CONTEXT_IDENTITY_BOUNDARY|CHILD_SEGMENT_IDENTITY_MISAUTHORED_AS_PARENT_SUPPORT_IDENTITY|STRUCTURED_RESPONSE_RELIABILITY_FAILURE_SURFACE_CLASSIFIED' \
  scripts/classify-structured-response-reliability-failure-surface.sh

grep -nE \
  'GENERATION_CONTROL_SURFACE_RECONCILED|validationGenerationSeed|AVAILABLE_OR_POTENTIALLY_AVAILABLE_GENERATION_CONTROLS|SEPARATE_INTERVENTION_CLASS|CONVERSATION_ENGINE_GENERATION_REQUEST' \
  scripts/reconcile-generation-control-surface-inventory.sh

echo "CHARACTERIZATION_EVIDENCE=CONFIRMED"

echo
echo "=== VERIFY BOUNDED SAMPLE RESULT ==="
grep -nE \
  'Initial bounded characterization sample: 10 identical unseeded invocations|Do not authorize production intervention from raw variance alone' \
  scripts/define-bounded-unseeded-variance-characterization-contract.sh

grep -nE \
  'nine|9|ten|10|acceptance|line 22|line 20' \
  scripts/classify-preserved-unseeded-acceptance-boundary-failure.sh \
  scripts/investigate-structured-response-reliability-failure-surface.sh \
  scripts/classify-structured-response-reliability-failure-surface.sh \
  2>/dev/null |
  head -180 || true

echo
echo "=== VERIFY EXISTING SEEDED DIAGNOSTIC EVIDENCE ==="
grep -nE \
  'validationGenerationSeed|seeded|reproduc|temperature|top_p|top_k|production seed' \
  scripts/classify-adaptive-detail-stability-from-seeded-evidence.sh \
  scripts/classify-scoped-matilda-generation-control-contract.sh \
  scripts/determine-adaptive-detail-production-stability-acceptance-contract.sh \
  2>/dev/null |
  head -220 || true

echo
echo "=== INTERVENTION DECISION BOUNDARY ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR=INTERVENTION_DECISION_BOUNDARY

ESTABLISHED_PROBLEM=
  A bounded ordinary unseeded sample produced a repeatable acceptance-boundary
  failure at a known structured semantic identity boundary.

  Nine of ten observed runs authored an unsupplied parent support identity and
  were correctly rejected by deterministic provenance validation.

FAILURE_SIGNIFICANCE=
  MATERIAL

  This is not merely surface wording variance.

  The observed behavior repeatedly crosses an established semantic acceptance
  boundary and prevents otherwise structured generation from being accepted.

DETERMINISTIC_VALIDATOR_DECISION=
  PRESERVE

  The validator is enforcing the established supplied-source provenance
  contract and must not be weakened to accommodate model-authored invalid
  identities.

PRODUCTION_INTERVENTION_DECISION=
  NOT_YET_AUTHORIZED

  The evidence establishes a reliability problem but does not yet identify a
  production-safe remedy.

BOUNDED_EXPERIMENT_DECISION=
  JUSTIFIED

  The observed 9-of-10 acceptance-boundary failure is sufficient to justify a
  controlled diagnostic experiment comparing narrowly scoped intervention
  candidates.

EXPERIMENT_PURPOSE=
  Determine whether a bounded candidate can materially reduce or eliminate the
  known structured semantic identity failure while preserving established
  response semantics and deterministic validation boundaries.

CANDIDATE_CLASS_1=
  REQUEST_SCOPED_GENERATION_CONTROL

  Existing validationGenerationSeed provides a repository-supported diagnostic
  control seam.

  Seeded evidence may be used to characterize reproducibility and candidate
  behavior but must not itself be treated as authorization for a production
  seed.

CANDIDATE_CLASS_2=
  IDENTITY_PRESENTATION_INTERVENTION

  Existing evidence identifies parent-versus-child identity presentation as a
  separate plausible intervention class.

  A bounded presentation experiment may therefore be compared against
  generation-control behavior without changing runtime identity semantics.

SAMPLING_CONTROLS=
  temperature
  top_p
  top_k

  These remain candidate generation-policy surfaces, but current evidence does
  not justify changing them before a narrower experiment establishes a reason
  to do so.

MODEL_CHANGE=
  DEFERRED

  Changing the configured model is broader than necessary for the first bounded
  intervention experiment.

RETRY_OR_MULTI_INVOCATION=
  NOT_JUSTIFIED

  The current evidence does not justify adding retries or additional model
  invocations.

EXPERIMENT_CONSTRAINTS=
  - preserve one semantic generation invocation per measured run;
  - preserve deterministic fail-closed provenance validation;
  - preserve structured response schema;
  - preserve selectedContextSegments runtime identity;
  - preserve supportSourceReferences parent-source semantics;
  - preserve Conversation Engine semantic authority boundaries;
  - do not alter semantic history;
  - do not modify production generation policy;
  - isolate each candidate so causal interpretation remains possible;
  - compare against the established ordinary unseeded baseline.

SUCCESS_CRITERION_REQUIRED=
  YES

  Before executing an intervention experiment, define the exact acceptance
  criteria, fixture, sample boundary, candidate under test, baseline comparison,
  semantic-regression checks, and rollback boundary.

PRODUCTION_PROMOTION_GATE=
  A diagnostic candidate must not be promoted merely because it improves this
  fixture.

  Promotion requires evidence that it addresses the known failure while
  preserving the wider established structured-response behavior expected from
  the Conversation Engine.

CORRIDOR_5_RESULT=
  BOUNDED_INTERVENTION_EXPERIMENT_JUSTIFIED

IMPLEMENTATION_AUTHORIZED=NO
IMPLEMENTATION_STARTED=NO
PRODUCTION_CHANGE=NONE

PHASE_1_RESULT=
  PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION_COMPLETE

NEXT_PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
NEXT_ACTION=DEFINE_BOUNDED_INTERVENTION_EXPERIMENT_ACCEPTANCE_CONTRACT
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-generation-stability-intervention-decision-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-generation-stability-intervention-decision-boundary.sh
git diff --cached --check
git commit -m "Classify generation stability intervention boundary"
git push
