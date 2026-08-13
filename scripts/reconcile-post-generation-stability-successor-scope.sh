#!/usr/bin/env bash
set -euo pipefail

echo "=== POST-GENERATION-STABILITY SUCCESSOR SCOPE RECONCILIATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor b816a7af HEAD

echo "FINAL_DR_CHECKPOINT=20260813_111438"
echo "GENERATION_STABILITY_MILESTONE=COMPLETE"

echo
echo "=== VERIFY COMPLETED GENERATION STABILITY BOUNDARY ==="
closure="scripts/close-conversation-engine-generation-stability-milestone.sh"
test -f "$closure"
grep -q 'GENERATION_STABILITY_MILESTONE=' "$closure"
grep -q 'COMPLETE_WITH_PRODUCTION_GENERATION_INSTABILITY_EXPLICITLY_ESTABLISHED' "$closure"
grep -q 'PRODUCTION_GENERATION_POLICY=' "$closure"
grep -q 'UNCHANGED_UNCONFIGURED_UNSEEDED' "$closure"
echo "GENERATION_STABILITY_CLOSURE=CONFIRMED"

echo
echo "=== DISCOVER DEFERRED / INCOMPLETE CONVERSATION ENGINE SURFACES ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude='*.map' \
  'cross.turn|cross-turn|transition validation|transition.*valid|deferred|not implemented|next milestone|next corridor|successor|investigation lifecycle' \
  scripts server app packages src 2>/dev/null || true

echo
echo "=== INVESTIGATION LIFECYCLE CURRENT CAPABILITY EVIDENCE ==="
for artifact in \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts \
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts \
  scripts/validate-investigation-lifecycle-prior-context-transport.test.ts \
  scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts
do
  if [[ -f "$artifact" ]]; then
    echo "PRESENT=$artifact"
  fi
done

echo
echo "=== SUCCESSOR SELECTION BOUNDARY ==="
cat <<'MAP'
COMPLETED_MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

FINAL_DR_CHECKPOINT=
20260813_111438

CURRENT_PRODUCTION_GENERATION_CONDITION=
KNOWN_UNSTABLE_AND_EXPLICITLY_DEFERRED

GENERATION_STABILITY_REOPENED=
NO

SUCCESSOR_SELECTION_MODE=
EVIDENCE_FIRST_SCOPE_RECONCILIATION

CANDIDATE_SUCCESSOR=
INVESTIGATION_LIFECYCLE_CROSS_TURN_CONTINUITY

CANDIDATE_STATUS=
NOT_YET_SELECTED

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

NEXT_ACTION=
CLASSIFY_REPOSITORY_SUPPORTED_SUCCESSOR_MILESTONE
MAP
