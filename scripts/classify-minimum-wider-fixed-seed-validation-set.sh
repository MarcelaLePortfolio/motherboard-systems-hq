#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY MINIMUM WIDER FIXED-SEED VALIDATION SET ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY FIXTURE-SET CHECKPOINT ==="
expected_head="8ab146ce"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches wider semantic-preservation fixture-set checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-minimum-wider-fixed-seed-validation-set\.sh$|^ M scripts/classify-minimum-wider-fixed-seed-validation-set\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "FIXTURE_SET_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY FIXTURE-SET CLASSIFICATION ==="
grep -nE \
  'FIXTURE_SET_RESULT=|PARTIALLY_READY|READY_WITH_EXISTING_SEEDED_LIVE_FIXTURE=|SELECTED_CONTEXT_ADAPTIVE_DETAIL|REQUIRES_BOUNDED_SEEDED_ADAPTATION_CLASSIFICATION=|REQUIRES_DECISION_ON_STATIC_VS_LIVE_SEEDED_EVIDENCE=|NEXT_ACTION=|CLASSIFY_MINIMUM_WIDER_FIXED_SEED_VALIDATION_SET' \
  scripts/classify-wider-semantic-preservation-fixture-set.sh

echo "FIXTURE_SET_CLASSIFICATION=CONFIRMED"

echo
echo "=== VERIFY WIDER VALIDATION CONTRACT ==="
grep -nE \
  'REQUIRED_RESPONSIBILITY_CLASSES=|ACCEPTANCE_REQUIREMENT=|FAIL_CLOSED_REQUIREMENT=|SEMANTIC_QUALITY_REQUIREMENT=|CANDIDATE_SURVIVAL_RULE=|PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO' \
  scripts/define-wider-fixed-seed-semantic-preservation-validation-contract.sh

echo "WIDER_VALIDATION_CONTRACT=CONFIRMED"

echo
echo "=== INSPECT LIVE REASONING ACCEPTANCE SURFACE ==="
sed -n '1,240p' scripts/validate-reasoning-composition-live.ts

echo
echo "=== INSPECT LIVE STRUCTURED-EVIDENCE ACCEPTANCE SURFACE ==="
sed -n '1,260p' scripts/validate-structured-evidence-object-live.ts

echo
echo "=== INSPECT LIVE SUPPORT-DRIVEN SOURCE-EXCERPT SURFACE ==="
sed -n '1,260p' scripts/validate-support-driven-source-excerpt-live.ts

echo
echo "=== INSPECT SOURCE-EXCERPT-FIRST LIVE SURFACE ==="
sed -n '1,260p' scripts/validate-source-excerpt-first-live.ts

echo
echo "=== INSPECT STATIC CONTRACT RESPONSIBILITIES ==="
for file in \
  scripts/utils/ollamaChat.summary-composition.test.ts \
  scripts/utils/ollamaChat.boundary-composition.test.ts \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts \
  scripts/utils/ollamaChat.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts
do
  echo
  echo "--- $file ---"
  sed -n '1,220p' "$file"
done

echo
echo "=== MINIMUM VALIDATION SET CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=GENERATION_CONTROL_SEMANTIC_PRESERVATION_BOUNDARY
UNIT=MINIMUM_WIDER_FIXED_SEED_VALIDATION_SET

GOVERNING_RULE=
  The wider validation must test fixed-seed semantic behavior where semantic
  model authorship is materially exercised, while separately preserving static
  deterministic and contract enforcement coverage.

STATIC_TEST_ROLE=
  Static contract tests remain necessary regression guards.

  They are not, by themselves, evidence that fixed sampling preserves
  model-authored semantic behavior because most static tests do not exercise
  live semantic generation under validationGenerationSeed=424242.

LIVE_SEEDED_ROLE=
  Live seeded diagnostics are required for semantic responsibilities whose
  acceptance depends materially on model-authored output.

MINIMUM_LIVE_SEEDED_RESPONSIBILITY_SET=
  1. Reasoning / Explanation Composition
  2. Evidence / Support Provenance
  3. Selected Context / Adaptive Detail

RATIONALE=
  These three responsibility classes already have established live semantic
  fixtures and independently defined acceptance behavior.

  Selected Context / Adaptive Detail already has a seeded live fixture and has
  passed the bounded ten-run diagnostic.

  Reasoning / Explanation and Evidence / Support Provenance have established
  live fixtures but require the smallest seed-only diagnostic adaptations.

MINIMUM_STATIC_REGRESSION_SET=
  1. Summary Composition
  2. Boundary Composition
  3. Investigation Lifecycle
  4. Durable Interpretation
  5. Structured Response / Fail-Closed Enforcement

RATIONALE_FOR_STATIC_SET=
  These responsibilities have established deterministic contract surfaces that
  can verify the fixed-seed experiment does not require schema, validation,
  ownership, or structural relaxations.

  Current repository evidence does not justify inventing new live seeded
  fixtures for these responsibilities before the existing live semantic set is
  exercised.

SUMMARY_COMPOSITION=
  STATIC_ACCEPTANCE_SURFACE:
    scripts/utils/ollamaChat.summary-composition.test.ts

  LIVE_SEEDED_ADAPTATION:
    NOT_REQUIRED_FOR_MINIMUM_SET

REASONING_EXPLANATION=
  STATIC_ACCEPTANCE_SURFACES:
    scripts/utils/ollamaChat.reasoning-composition.test.ts
    scripts/utils/ollamaChat.explanation-request.test.ts
    scripts/utils/ollamaChat.explanation-status.test.ts

  LIVE_ACCEPTANCE_SURFACE:
    scripts/validate-reasoning-composition-live.ts

  FIXED_SEED_ADAPTATION:
    REQUIRED

  ADAPTATION_BOUNDARY:
    Add validationGenerationSeed=424242 to the existing live fixture only.
    Preserve message, context, assertions, prompt path, schema, and validator.

EVIDENCE_SUPPORT_PROVENANCE=
  STATIC_ACCEPTANCE_SURFACES:
    scripts/utils/ollamaChat.structured-evidence-object.test.ts
    scripts/utils/ollamaChat.support-source-production.test.ts
    scripts/utils/ollamaChat.support-source-references.test.ts
    scripts/utils/ollamaChat.support-validation-observer.test.ts
    scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts
    scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts

  LIVE_ACCEPTANCE_SURFACES:
    scripts/validate-structured-evidence-object-live.ts
    scripts/validate-support-driven-source-excerpt-live.ts
    scripts/validate-source-excerpt-first-live.ts

  MINIMUM_FIXED_SEED_LIVE_FIXTURE:
    scripts/validate-structured-evidence-object-live.ts

  FIXED_SEED_ADAPTATION:
    REQUIRED

  ADAPTATION_BOUNDARY:
    Add validationGenerationSeed=424242 to the existing live fixture only.
    Preserve message, supplied evidence, assertions, prompt path, schema, and
    deterministic provenance validation.

  ADDITIONAL_LIVE_FIXTURES:
    DEFER_UNLESS_PRIMARY_EVIDENCE_FIXTURE_FAILS_OR_PROVES_INSUFFICIENT

BOUNDARY_COMPOSITION=
  STATIC_ACCEPTANCE_SURFACE:
    scripts/utils/ollamaChat.boundary-composition.test.ts

  LIVE_SEEDED_ADAPTATION:
    NOT_REQUIRED_FOR_MINIMUM_SET

SELECTED_CONTEXT_ADAPTIVE_DETAIL=
  STATIC_ACCEPTANCE_SURFACES:
    scripts/utils/ollamaChat.selected-context-observer.test.ts
    scripts/utils/ollamaChat.child-identity-presentation.test.ts
    scripts/utils/ollamaChat.parent-support-identity-prompt.test.ts
    scripts/validate-adaptive-detail-mixed-content-criteria.test.ts

  SEEDED_LIVE_ACCEPTANCE_SURFACE:
    scripts/validate-adaptive-detail-mixed-content-seeded-live.ts

  FIXED_SEED_ADAPTATION:
    ALREADY_ESTABLISHED

  CURRENT_RESULT:
    10_OF_10_SEMANTIC_PASS

INVESTIGATION_LIFECYCLE=
  STATIC_ACCEPTANCE_SURFACE:
    scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

  LIVE_SEEDED_ADAPTATION:
    NOT_REQUIRED_FOR_MINIMUM_SET

DURABLE_INTERPRETATION=
  STATIC_ACCEPTANCE_SURFACE:
    scripts/utils/ollamaChat.test.ts

  LIVE_SEEDED_ADAPTATION:
    NOT_REQUIRED_FOR_MINIMUM_SET

STRUCTURED_RESPONSE_FAIL_CLOSED=
  STATIC_ACCEPTANCE_SURFACES:
    scripts/guard-ollama-response-contract.sh
    scripts/utils/ollamaChat.test.ts
    scripts/utils/ollamaChat.support-validation-observer.test.ts
    scripts/utils/ollamaChat.support-source-references.test.ts
    scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

  VALIDATION_RULE:
    These guards must remain passing before and after seeded live diagnostics.

MINIMUM_SEEDED_ADAPTATION_COUNT=
  2

MINIMUM_NEW_SEEDED_ADAPTATIONS=
  scripts/validate-reasoning-composition-fixed-seed-live.ts
  scripts/validate-structured-evidence-object-fixed-seed-live.ts

CAUSAL_ISOLATION_RULE=
  Each adaptation may differ from its existing live fixture only by supplying:
    validationGenerationSeed=424242

  No other semantic, structural, prompt, schema, validator, model, or generation
  control change is authorized.

RUN_SHAPE=
  First validate each seeded adaptation once to establish fixture correctness.

  If both pass, classify the bounded repeated-run requirement before performing
  any wider repeated sample.

  Do not silently escalate directly to repeated runs.

FAILURE_RULE=
  If either first seeded adaptation fails, preserve that artifact and classify
  the specific semantic failure before modifying any candidate or fixture.

MINIMUM_VALIDATION_SET_RESULT=
  CLASSIFIED

IMPLEMENTATION_AUTHORIZED=
  TWO_DIAGNOSTIC_SEED_ONLY_FIXTURE_ADAPTATIONS

PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_GENERATION_POLICY=UNCHANGED
PRODUCTION_CHANGE=NONE

NEXT_ACTION=
  IMPLEMENT_MINIMUM_WIDER_FIXED_SEED_FIXTURE_ADAPTATIONS
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-minimum-wider-fixed-seed-validation-set\.sh$' ||
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

git add scripts/classify-minimum-wider-fixed-seed-validation-set.sh
git diff --cached --check
git commit -m "Classify minimum wider fixed seed validation set"
git push
