#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY WIDER SEMANTIC PRESERVATION FIXTURE SET ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY CONTRACT CHECKPOINT ==="
expected_head="f81aa31f"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches wider semantic-preservation contract checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-wider-semantic-preservation-fixture-set\.sh$|^ M scripts/classify-wider-semantic-preservation-fixture-set\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "SEMANTIC_PRESERVATION_CONTRACT_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CONTRACT RESPONSIBILITY CLASSES ==="
grep -nE \
  'Summary Composition|Reasoning / Explanation Composition|Evidence / Support Provenance|Boundary Composition|Selected Context / Adaptive Detail|Investigation Lifecycle|Durable Interpretation|Structured Response Contract / Fail-Closed Behavior|CLASSIFY_WIDER_SEMANTIC_PRESERVATION_FIXTURE_SET' \
  scripts/define-wider-fixed-seed-semantic-preservation-validation-contract.sh

echo "RESPONSIBILITY_CLASSES=CONFIRMED"

echo
echo "=== SUMMARY COMPOSITION SURFACES ==="
find scripts -maxdepth 2 -type f |
  sort |
  grep -E \
    'ollamaChat\.summary-composition\.test\.ts|validate-.*summary.*live|summary-composition' \
  || true

echo
echo "=== REASONING / EXPLANATION SURFACES ==="
find scripts -maxdepth 2 -type f |
  sort |
  grep -E \
    'ollamaChat\.(reasoning-composition|explanation-request|explanation-status)\.test\.ts|validate-reasoning-composition-live\.ts' \
  || true

echo
echo "=== EVIDENCE / SUPPORT PROVENANCE SURFACES ==="
find scripts -maxdepth 2 -type f |
  sort |
  grep -E \
    'ollamaChat\.(structured-evidence-object|support-source-production|support-source-references|support-validation-observer|evidence-sufficiency-gate|explicit-evidence-request-context)\.test\.ts|validate-(structured-evidence-object|support-driven-source-excerpt|source-excerpt-first)-live\.ts' \
  || true

echo
echo "=== BOUNDARY COMPOSITION SURFACES ==="
find scripts -maxdepth 2 -type f |
  sort |
  grep -E \
    'ollamaChat\.boundary-composition\.test\.ts|validate-.*boundary.*live' \
  || true

echo
echo "=== SELECTED CONTEXT / ADAPTIVE DETAIL SURFACES ==="
find scripts -maxdepth 2 -type f |
  sort |
  grep -E \
    'ollamaChat\.(selected-context-observer|child-identity-presentation|parent-support-identity-prompt)\.test\.ts|validate-adaptive-detail-mixed-content-(live|seeded-live)\.ts|validate-adaptive-detail-mixed-content-criteria\.test\.ts' \
  || true

echo
echo "=== INVESTIGATION LIFECYCLE SURFACES ==="
find scripts -maxdepth 2 -type f |
  sort |
  grep -E \
    'ollamaChat\.investigation-lifecycle-contract\.test\.ts|investigation-lifecycle.*live|selected-context-investigation-lifecycle' \
  || true

echo
echo "=== DURABLE INTERPRETATION SURFACES ==="
find scripts -maxdepth 2 -type f |
  sort |
  grep -E \
    'durable-interpretation|ollamaChat\.test\.ts' \
  || true

echo
echo "=== STRUCTURED RESPONSE / FAIL-CLOSED SURFACES ==="
find scripts -maxdepth 2 -type f |
  sort |
  grep -E \
    'guard-ollama-response-contract\.sh|ollamaChat\.test\.ts|support-validation-observer|support-source-references|investigation-lifecycle-contract' \
  || true

echo
echo "=== SEED-ADAPTABILITY SIGNALS IN LIVE VALIDATORS ==="
for file in \
  scripts/validate-reasoning-composition-live.ts \
  scripts/validate-structured-evidence-object-live.ts \
  scripts/validate-support-driven-source-excerpt-live.ts \
  scripts/validate-source-excerpt-first-live.ts \
  scripts/validate-adaptive-detail-mixed-content-live.ts
do
  if [[ -f "$file" ]]; then
    echo "--- $file ---"
    grep -nE \
      'ollamaChat\(|validationGenerationSeed|projectContextExcerpts|projectContextSegmentCandidates|supportSourceReferences|investigationLifecycle|durableInterpretation|explanationStatus|selectedContextSegments' \
      "$file" |
      head -120 || true
  fi
done

echo
echo "=== FIXTURE-SET CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=GENERATION_CONTROL_SEMANTIC_PRESERVATION_BOUNDARY
UNIT=WIDER_SEMANTIC_PRESERVATION_FIXTURE_SET

CLASSIFICATION_RULE=
  Prefer existing independently established test and live-validation surfaces.

  Do not create seeded adaptations until the repository evidence establishes
  that no existing seeded-capable surface already covers the responsibility.

SUMMARY_COMPOSITION=
  PRIMARY_STATIC_SURFACE:
    scripts/utils/ollamaChat.summary-composition.test.ts

  LIVE_SEEDED_SURFACE:
    NOT_YET_ESTABLISHED

REASONING_EXPLANATION=
  PRIMARY_STATIC_SURFACES:
    scripts/utils/ollamaChat.reasoning-composition.test.ts
    scripts/utils/ollamaChat.explanation-request.test.ts
    scripts/utils/ollamaChat.explanation-status.test.ts

  PRIMARY_LIVE_SURFACE:
    scripts/validate-reasoning-composition-live.ts

  SEEDED_ADAPTATION_STATUS:
    REQUIRES_CLASSIFICATION

EVIDENCE_SUPPORT_PROVENANCE=
  PRIMARY_STATIC_SURFACES:
    scripts/utils/ollamaChat.structured-evidence-object.test.ts
    scripts/utils/ollamaChat.support-source-production.test.ts
    scripts/utils/ollamaChat.support-source-references.test.ts
    scripts/utils/ollamaChat.support-validation-observer.test.ts
    scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts
    scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts

  PRIMARY_LIVE_SURFACES:
    scripts/validate-structured-evidence-object-live.ts
    scripts/validate-support-driven-source-excerpt-live.ts
    scripts/validate-source-excerpt-first-live.ts

  SEEDED_ADAPTATION_STATUS:
    REQUIRES_CLASSIFICATION

BOUNDARY_COMPOSITION=
  PRIMARY_STATIC_SURFACE:
    scripts/utils/ollamaChat.boundary-composition.test.ts

  LIVE_SEEDED_SURFACE:
    NOT_YET_ESTABLISHED

SELECTED_CONTEXT_ADAPTIVE_DETAIL=
  PRIMARY_STATIC_SURFACES:
    scripts/utils/ollamaChat.selected-context-observer.test.ts
    scripts/utils/ollamaChat.child-identity-presentation.test.ts
    scripts/utils/ollamaChat.parent-support-identity-prompt.test.ts
    scripts/validate-adaptive-detail-mixed-content-criteria.test.ts

  PRIMARY_LIVE_SURFACE:
    scripts/validate-adaptive-detail-mixed-content-live.ts

  SEEDED_LIVE_SURFACE:
    scripts/validate-adaptive-detail-mixed-content-seeded-live.ts

  SEEDED_ADAPTATION_STATUS:
    ALREADY_ESTABLISHED

INVESTIGATION_LIFECYCLE=
  PRIMARY_STATIC_SURFACE:
    scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

  LIVE_SEEDED_SURFACE:
    NOT_YET_ESTABLISHED

DURABLE_INTERPRETATION=
  PRIMARY_STATIC_SURFACE:
    scripts/utils/ollamaChat.test.ts

  LIVE_SEEDED_SURFACE:
    NOT_YET_ESTABLISHED

STRUCTURED_RESPONSE_FAIL_CLOSED=
  PRIMARY_STATIC_AND_GUARD_SURFACES:
    scripts/guard-ollama-response-contract.sh
    scripts/utils/ollamaChat.test.ts
    scripts/utils/ollamaChat.support-validation-observer.test.ts
    scripts/utils/ollamaChat.support-source-references.test.ts
    scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

  SEEDED_VALIDATION_RULE=
    Fail-closed behavior must be validated independently of whether semantic
    content becomes reproducible under a fixed seed.

FIXTURE_SET_RESULT=
  PARTIALLY_READY

READY_WITH_EXISTING_SEEDED_LIVE_FIXTURE=
  SELECTED_CONTEXT_ADAPTIVE_DETAIL

READY_WITH_EXISTING_STATIC_CONTRACT_TESTS=
  SUMMARY_COMPOSITION
  REASONING_EXPLANATION
  EVIDENCE_SUPPORT_PROVENANCE
  BOUNDARY_COMPOSITION
  SELECTED_CONTEXT_ADAPTIVE_DETAIL
  INVESTIGATION_LIFECYCLE
  DURABLE_INTERPRETATION
  STRUCTURED_RESPONSE_FAIL_CLOSED

REQUIRES_BOUNDED_SEEDED_ADAPTATION_CLASSIFICATION=
  REASONING_EXPLANATION
  EVIDENCE_SUPPORT_PROVENANCE

REQUIRES_DECISION_ON_STATIC_VS_LIVE_SEEDED_EVIDENCE=
  SUMMARY_COMPOSITION
  BOUNDARY_COMPOSITION
  INVESTIGATION_LIFECYCLE
  DURABLE_INTERPRETATION
  STRUCTURED_RESPONSE_FAIL_CLOSED

PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_GENERATION_POLICY=UNCHANGED
PRODUCTION_CHANGE=NONE

NEXT_ACTION=
  CLASSIFY_MINIMUM_WIDER_FIXED_SEED_VALIDATION_SET
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-wider-semantic-preservation-fixture-set\.sh$' ||
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

git add scripts/classify-wider-semantic-preservation-fixture-set.sh
git diff --cached --check
git commit -m "Classify wider semantic preservation fixture set"
git push
