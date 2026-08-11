#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY MINIMUM SOURCE-EXCERPT-FIRST FIXED-SEED DIAGNOSTIC ADAPTATION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY COMPATIBLE FIXTURE CLASSIFICATION ANCESTOR ==="
required_ancestor="3162507d"

if ! git merge-base --is-ancestor "$required_ancestor" HEAD; then
  echo "STOP: required compatible-fixture investigation ancestor $required_ancestor is absent."
  exit 2
fi

echo "REQUIRED_COMPATIBLE_FIXTURE_ANCESTOR_PRESENT=$required_ancestor"

echo
echo "=== VERIFY SOURCE-EXCERPT-FIRST COMPATIBILITY ==="
fixture="scripts/validate-source-excerpt-first-live.ts"

grep -nE \
  'projectContextExcerpts|projectContextSegmentCandidates|supportSourceReferences|sourceStartLine|sourceEndLine' \
  "$fixture"

if ! grep -q 'projectContextSegmentCandidates' "$fixture"; then
  echo "STOP: source-excerpt-first fixture is not compatible with selected-context validation."
  exit 2
fi

if grep -q 'validationGenerationSeed' "$fixture"; then
  echo "STOP: source-excerpt-first fixture is no longer an unseeded baseline."
  exit 2
fi

echo "SOURCE_EXCERPT_FIRST_COMPATIBILITY=CONFIRMED"
echo "SOURCE_EXCERPT_FIRST_BASELINE=UNSEEDED"

echo
echo "=== VERIFY EXISTING VALIDATION SEED SEAM ==="
grep -nE \
  'validationGenerationSeed|options.*seed|seed:' \
  scripts/utils/ollamaChat.ts

echo "VALIDATION_SEED_SEAM=CONFIRMED"

echo
echo "=== VERIFY PRODUCTION WORKFLOW REMAINS UNSEEDED ==="
if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow unexpectedly supplies validationGenerationSeed."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_VALIDATION_SEED=ABSENT"

echo
echo "=== CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=GENERATION_CONTROL_SEMANTIC_PRESERVATION_BOUNDARY
UNIT=SOURCE_EXCERPT_FIRST_FIXED_SEED_DIAGNOSTIC_ADAPTATION

TARGET_BASELINE_FIXTURE=
  scripts/validate-source-excerpt-first-live.ts

TARGET_RESPONSIBILITY=
  EVIDENCE_AND_SUPPORT_PROVENANCE

BASELINE_COMPATIBILITY=
  CONFIRMED

BASELINE_SEED_STATUS=
  UNSEEDED

FIXED_DIAGNOSTIC_SEED=
  424242

SMALLEST_SAFE_ADAPTATION=
  CREATE_ONE_DIAGNOSTIC_COPY_OF_SOURCE_EXCERPT_FIRST_LIVE_FIXTURE

PERMITTED_DIFFERENCE=
  ADD_ONLY_validationGenerationSeed_424242_TO_EXISTING_OLLAMA_CONTEXT

PRESERVE_EXACTLY=
  USER_MESSAGE
  PROJECT_CONTEXT_EXCERPTS
  PROJECT_CONTEXT_SEGMENT_CANDIDATES
  ACCEPTANCE_ASSERTIONS
  SUPPORT_PROVENANCE_EXPECTATIONS
  SELECTED_CONTEXT_IDENTITIES
  MODEL
  PROMPT
  STRUCTURED_RESPONSE_SCHEMA
  DETERMINISTIC_VALIDATORS
  PRODUCTION_WORKFLOW

RATIONALE=
  The source-excerpt-first live validator already satisfies the current
  selected-context candidate identity contract and independently exercises
  evidence and support-provenance behavior.

  A diagnostic copy differing only by validationGenerationSeed=424242 can
  therefore compare the supported fixed-seed candidate against an established
  repository semantic responsibility without repairing the fixture or
  relaxing runtime validation.

  This adaptation is diagnostic only. It does not establish or authorize a
  production generation policy.

IMPLEMENTATION_SCOPE=
  ONE_NEW_DIAGNOSTIC_FIXTURE_ONLY

AUTHORIZED_TARGET=
  scripts/validate-source-excerpt-first-fixed-seed-live.ts

FIXTURE_REPAIR_AUTHORIZED=
  NO

PROMPT_CHANGE_AUTHORIZED=
  NO

VALIDATOR_RELAXATION_AUTHORIZED=
  NO

SCHEMA_CHANGE_AUTHORIZED=
  NO

MODEL_CHANGE_AUTHORIZED=
  NO

GENERATION_CONTROL_CHANGE_AUTHORIZED=
  FIXED_VALIDATION_SEED_424242_IN_DIAGNOSTIC_FIXTURE_ONLY

REPEATED_RUNS_AUTHORIZED=
  NO

SINGLE_DIAGNOSTIC_RUN_AFTER_IMPLEMENTATION=
  AUTHORIZED

PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_GENERATION_POLICY=UNCHANGED
PRODUCTION_CHANGE=NONE

CLASSIFICATION_RESULT=
  MINIMUM_SOURCE_EXCERPT_FIRST_SEED_ONLY_ADAPTATION_CLASSIFIED

NEXT_ACTION=
  IMPLEMENT_MINIMUM_SOURCE_EXCERPT_FIRST_FIXED_SEED_DIAGNOSTIC_ADAPTATION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-minimum-source-excerpt-first-fixed-seed-diagnostic-adaptation\.sh$' ||
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
