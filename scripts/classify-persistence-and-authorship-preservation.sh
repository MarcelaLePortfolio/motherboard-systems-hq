#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PERSISTENCE AND AUTHORSHIP PRESERVATION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="6440cdec"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches validation timing checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-persistence-and-authorship-preservation\.sh$|^ M scripts/classify-persistence-and-authorship-preservation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "VALIDATION_TIMING_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING BOUNDARIES ==="

grep -q 'WORKFLOW_IEL_PERSISTENCE_OWNERSHIP=' scripts/classify-validation-timing-and-failure-boundary.sh
grep -q 'PRESERVED' scripts/classify-validation-timing-and-failure-boundary.sh
grep -q 'MATILDA_SEMANTIC_AUTHORITY=' scripts/classify-validation-timing-and-failure-boundary.sh
grep -q 'ONE_OLLAMA_INVOCATION=' scripts/classify-validation-timing-and-failure-boundary.sh

echo "GOVERNING_BOUNDARIES=CONFIRMED"

echo
echo "=== CLASSIFY PERSISTENCE AND AUTHORSHIP PRESERVATION ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

MILESTONE_CANDIDATE=
  INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION

PHASE=
  SUCCESSOR_CAPABILITY_READINESS_CLASSIFICATION

CORRIDOR=
  PERSISTENCE_AND_AUTHORSHIP_PRESERVATION

MATILDA_SEMANTIC_AUTHORSHIP=
  PRESERVED

INVESTIGATION_LIFECYCLE_FACT_AUTHOR=
  MATILDA

DETERMINISTIC_RUNTIME_ROLE=
  STRUCTURAL_AND_RELATIONSHIP_VALIDATION_ONLY

WORKFLOW_IEL_PERSISTENCE_OWNERSHIP=
  PRESERVED

CURRENT_LIFECYCLE_PERSISTENCE_RULE=
  PERSIST_ONLY_AFTER_STRUCTURAL_AND_CROSS_TURN_VALIDATION_PASS

INVALID_CURRENT_LIFECYCLE_PERSISTENCE=
  PROHIBITED

PRIOR_LIFECYCLE_PERSISTENCE_MUTATION=
  NONE

PRIOR_LIFECYCLE_SELECTION=
  PRESERVED

PRIOR_LIFECYCLE_CONTEXT_CHANNEL=
  PRESERVED

SELECTED_HISTORY=
  PRESERVED

PROJECT_CONTEXT_EXCERPTS=
  PRESERVED

CONVERSATION_CONTEXT_RUNTIME=
  PRESERVED

REPLY_AND_DURABLE_INTERPRETATION_SEPARATION=
  PRESERVED

STRUCTURED_RESPONSE_CONTRACT=
  PRESERVED

LIVING_DRAFT_DERIVATION_FROM_IEL=
  PRESERVED

APPROVAL_PIPELINE=
  PRESERVED

ONE_USER_MESSAGE_ONE_WORKFLOW=
  PRESERVED

ONE_OLLAMA_INVOCATION=
  PRESERVED

DATABASE_SCHEMA_CHANGE_REQUIREMENT=
  NOT_ESTABLISHED

PARALLEL_PERSISTENCE_PATH=
  NOT_AUTHORIZED

PARALLEL_LIFECYCLE_READER=
  NOT_AUTHORIZED

SEMANTIC_FACT_REPAIR=
  NOT_AUTHORIZED

SEMANTIC_FACT_SYNTHESIS=
  NOT_AUTHORIZED

AUTHORITY_BOUNDARY_CLASSIFICATION=
  Runtime may reject an invalid relationship but may not replace, reinterpret,
  repair, synthesize, or otherwise author Investigation Lifecycle facts.

PERSISTENCE_BOUNDARY_CLASSIFICATION=
  Existing workflow persistence ownership remains authoritative.

  Cross-turn validation is inserted only as a bounded pre-persistence gate.

  A valid current lifecycle artifact continues through the existing durable IEL
  path unchanged.

  An invalid relationship prevents that current lifecycle artifact from becoming
  durable state and does not mutate the prior lifecycle artifact.

  No new persistence owner, database schema, context channel, or model invocation
  is required by this boundary.

PERSISTENCE_AND_AUTHORSHIP_PRESERVATION_CORRIDOR=
  COMPLETE

IMPLEMENTATION_READINESS=
  NOT_YET_ESTABLISHED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

NEXT_CORRIDOR=
  IMPLEMENTATION_READINESS_DISPOSITION

NEXT_ACTION=
  CLASSIFY_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION_READINESS_DISPOSITION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-persistence-and-authorship-preservation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside persistence/authorship preservation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
