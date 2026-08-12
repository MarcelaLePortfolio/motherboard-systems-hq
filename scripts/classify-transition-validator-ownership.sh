#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY TRANSITION VALIDATOR OWNERSHIP ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="310de4bf"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches transition-rule requirement checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-transition-validator-ownership\.sh$|^ M scripts/classify-transition-validator-ownership\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "TRANSITION_RULE_REQUIREMENT_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING REQUIREMENT ==="

grep -q 'TRANSITION_RULE_REQUIREMENT=' scripts/classify-cross-turn-transition-rule-requirement.sh
grep -q 'ESTABLISHED' scripts/classify-cross-turn-transition-rule-requirement.sh
grep -q 'DETERMINISTIC_RUNTIME_ROLE=' scripts/classify-cross-turn-transition-rule-requirement.sh
grep -q 'VALIDATE_RELATIONSHIP_ONLY' scripts/classify-cross-turn-transition-rule-requirement.sh
grep -q 'MATILDA_ROLE=' scripts/classify-cross-turn-transition-rule-requirement.sh
grep -q 'RETAIN_SEMANTIC_AUTHORSHIP' scripts/classify-cross-turn-transition-rule-requirement.sh

echo "GOVERNING_REQUIREMENT=CONFIRMED"

echo
echo "=== CLASSIFY VALIDATOR OWNERSHIP ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

MILESTONE_CANDIDATE=
  INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION

PHASE=
  SUCCESSOR_CAPABILITY_READINESS_CLASSIFICATION

CORRIDOR=
  TRANSITION_VALIDATOR_OWNERSHIP

SEMANTIC_LIFECYCLE_AUTHOR=
  MATILDA

CURRENT_ARTIFACT_VALIDATION_OWNER=
  DETERMINISTIC_RUNTIME

CROSS_TURN_TRANSITION_VALIDATION_OWNER=
  DETERMINISTIC_RUNTIME

WORKFLOW_ORCHESTRATION_OWNER=
  MATILDA_CHAT_WORKFLOW

VALIDATOR_OWNERSHIP_CLASSIFICATION=
  SHARED_DETERMINISTIC_LIFECYCLE_VALIDATION_BOUNDARY

OWNERSHIP_BASIS=
  Matilda owns the semantic facts contained in each Investigation Lifecycle
  artifact.

  Runtime already owns bounded structural validation of the current lifecycle
  artifact and deterministic orchestration of current and prior lifecycle
  context.

  Cross-turn validation evaluates only whether two Matilda-authored artifacts
  satisfy the established transition contract.

  Therefore transition validation belongs in the deterministic lifecycle
  validation boundary, invoked by workflow orchestration before durable
  persistence of the current lifecycle artifact.

VALIDATOR_MUST_ACCEPT=
  PRIOR_INVESTIGATION_LIFECYCLE_OR_NULL
  CURRENT_INVESTIGATION_LIFECYCLE_OR_NULL

VALIDATOR_MUST_RETURN=
  VALID_OR_INVALID_RELATIONSHIP

VALIDATOR_MUST_NOT=
  AUTHOR_LIFECYCLE_FACTS
  MODIFY_LIFECYCLE_ARTIFACTS
  REWRITE_INVESTIGATION_IDENTITY
  SYNTHESIZE_EVENTS
  SELECT_PRIOR_CONTEXT
  MODIFY_SELECTED_HISTORY
  MODIFY_PROJECT_CONTEXT
  INVOKE_OLLAMA

WORKFLOW_ROLE=
  SUPPLY_ALREADY_SELECTED_PRIOR_ARTIFACT_AND_CURRENT_MODEL_AUTHORED_ARTIFACT
  INVOKE_DETERMINISTIC_TRANSITION_VALIDATION
  PRESERVE_EXISTING_PERSISTENCE_OWNERSHIP

SHARED_VALIDATION_SURFACE_REUSE=
  REQUIRED_WHERE_ARCHITECTURALLY_COMPATIBLE

PARALLEL_LIFECYCLE_VALIDATION_SUBSYSTEM=
  NOT_AUTHORIZED

MATILDA_SEMANTIC_AUTHORITY=
  PRESERVED

WORKFLOW_IEL_PERSISTENCE_OWNERSHIP=
  PRESERVED

ONE_OLLAMA_INVOCATION=
  PRESERVED

IMPLEMENTATION_READINESS=
  NOT_YET_ESTABLISHED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

TRANSITION_VALIDATOR_OWNERSHIP_CORRIDOR=
  COMPLETE

NEXT_CORRIDOR=
  VALIDATION_TIMING_AND_FAILURE_BOUNDARY

NEXT_ACTION=
  CLASSIFY_VALIDATION_TIMING_AND_FAILURE_BOUNDARY
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-transition-validator-ownership\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside transition-validator ownership scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
