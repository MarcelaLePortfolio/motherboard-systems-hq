#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY REPOSITORY-SUPPORTED SUCCESSOR MILESTONE ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 2e55a898 HEAD

echo "=== VERIFY PREDECESSOR RECONCILIATION ==="
predecessor="scripts/reconcile-post-generation-stability-successor-scope.sh"
test -f "$predecessor"
grep -q 'GENERATION_STABILITY_MILESTONE=COMPLETE' "$predecessor"
grep -q 'INVESTIGATION_LIFECYCLE_CROSS_TURN_CONTINUITY' "$predecessor"
grep -q 'NOT_YET_SELECTED' "$predecessor"
echo "PREDECESSOR_RECONCILIATION=CONFIRMED"

echo
echo "=== VERIFY INVESTIGATION LIFECYCLE IMPLEMENTATION STATE ==="
required_artifacts=(
  scripts/classify-investigation-lifecycle-cross-turn-transition-validation-current-state.sh
  scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation-readiness.sh
  scripts/implement-investigation-lifecycle-cross-turn-transition-validation.sh
  scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation.sh
  scripts/assess-phase-2-investigation-lifecycle-closure.sh
  scripts/classify-phase-2-investigation-lifecycle-closure.sh
)

for artifact in "${required_artifacts[@]}"; do
  test -f "$artifact"
  echo "PRESENT=$artifact"
done

grep -q 'cross-turn transition validation — is now implemented and validated' \
  scripts/classify-phase-2-investigation-lifecycle-closure.sh

grep -q 'investigation identity that does not match prior lifecycle context' \
  scripts/utils/ollamaChat.ts

echo "CROSS_TURN_IDENTITY_CONTINUITY_VALIDATION=IMPLEMENTED"
echo "CROSS_TURN_TRANSITION_VALIDATION=IMPLEMENTED_AND_VALIDATED"

echo
echo "=== SUCCESSOR CLASSIFICATION ==="
cat <<'MAP'
COMPLETED_MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

GENERATION_STABILITY_REOPENED=
NO

INITIAL_CANDIDATE=
INVESTIGATION_LIFECYCLE_CROSS_TURN_CONTINUITY

INITIAL_CANDIDATE_CURRENTNESS=
STALE_AS_A_MISSING_CAPABILITY

REASON=
REPOSITORY_EVIDENCE_SHOWS_BOUNDED_CROSS_TURN_INVESTIGATION_IDENTITY_CONTINUITY_VALIDATION_ALREADY_IMPLEMENTED_AND_VALIDATED

SUCCESSOR_MILESTONE_SELECTION=
NOT_YET_ESTABLISHED

SUCCESSOR_SELECTION_REQUIREMENT=
RECONCILE_CURRENT_REMAINING_PROGRAM_GAPS_AFTER_GENERATION_STABILITY_CLOSURE

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

NEXT_ACTION=
RECONCILE_CURRENT_REMAINING_PROGRAM_GAPS_AND_SUCCESSOR_PRIORITY
MAP
