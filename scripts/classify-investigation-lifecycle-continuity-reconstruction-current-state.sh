#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE CONTINUITY RECONSTRUCTION CURRENT STATE ==="

REQUIRED_ANCESTOR="afa5e013"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: continuity investigation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY CLASSIFICATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-continuity-reconstruction-current-state\.sh$|^ M scripts/classify-investigation-lifecycle-continuity-reconstruction-current-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING INVESTIGATION ==="
test -f scripts/investigate-investigation-lifecycle-continuity-reconstruction-current-state.sh || {
  echo "STOP: defining investigation artifact is missing."
  exit 2
}

grep -nE \
  'INVESTIGATION_LIFECYCLE_CONTINUITY_RECONSTRUCTION_EVIDENCE_COLLECTED|CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH_REMAINS_COMPLETE|CONTINUITY_IMPLEMENTATION_NOT_STARTED|CROSS_TURN_TRANSITION_VALIDATION=DEFERRED' \
  scripts/investigate-investigation-lifecycle-continuity-reconstruction-current-state.sh

echo
echo "=== VERIFY PERSISTED LIFECYCLE REPRESENTATION ==="
grep -nE \
  'investigation_lifecycle_json|MatildaInvestigationLifecycleArtifact' \
  db/matilda-interpretation-runtime.ts |
head -n 160

echo
echo "=== VERIFY NO PRODUCTION LIFECYCLE JSON RECONSTRUCTION ==="
reconstruction="$(
  grep -R -n \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.sh' \
    -E 'JSON\.parse\(.*investigation_lifecycle_json|investigation_lifecycle_json.*JSON\.parse|parse.*Investigation.*Lifecycle' \
    db server scripts 2>/dev/null ||
  true
)"

if [[ -n "$reconstruction" ]]; then
  echo "STOP: production lifecycle reconstruction evidence exists and requires re-investigation:"
  printf '%s\n' "$reconstruction"
  exit 2
fi

echo "NO_PRODUCTION_LIFECYCLE_JSON_RECONSTRUCTION_CONFIRMED"

echo
echo "=== VERIFY CONVERSATION CONTEXT LIFECYCLE INDEPENDENCE ==="
context_lifecycle="$(
  grep -nE \
    'investigationLifecycle|investigation_lifecycle_json|investigationIdentity|governingQuestion|lifecycleDetermination' \
    server/matilda-conversation-context-runtime.ts ||
  true
)"

if [[ -n "$context_lifecycle" ]]; then
  echo "STOP: Conversation Context Runtime now contains semantic Investigation Lifecycle state:"
  printf '%s\n' "$context_lifecycle"
  exit 2
fi

echo "CONVERSATION_CONTEXT_RUNTIME_LIFECYCLE_INDEPENDENT"

echo
echo "=== VERIFY SELECTED HISTORY LIFECYCLE INDEPENDENCE ==="
history_lifecycle="$(
  grep -R -n \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.sh' \
    -E 'selectedHistory.*(investigationLifecycle|investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination)|(investigationLifecycle|investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination).*selectedHistory' \
    server db scripts 2>/dev/null ||
  true
)"

if [[ -n "$history_lifecycle" ]]; then
  echo "STOP: selectedHistory now carries semantic Investigation Lifecycle evidence:"
  printf '%s\n' "$history_lifecycle"
  exit 2
fi

echo "SELECTED_HISTORY_SEMANTIC_LIFECYCLE_ABSENT"

echo
echo "=== VERIFY EXISTING LIFECYCLE PROVIDER BOUNDARY ==="
test -f server/matilda-interpretation-lifecycle-provider.ts || {
  echo "STOP: lifecycle provider is missing."
  exit 2
}

provider_semantics="$(
  grep -nE \
    'investigationLifecycle|investigation_lifecycle_json|investigationIdentity|governingQuestion|lifecycleDetermination' \
    server/matilda-interpretation-lifecycle-provider.ts ||
  true
)"

if [[ -n "$provider_semantics" ]]; then
  echo "STOP: lifecycle provider now contains semantic Investigation Lifecycle state:"
  printf '%s\n' "$provider_semantics"
  exit 2
fi

echo "LIFECYCLE_PROVIDER_NOT_SEMANTIC_INVESTIGATION_CONTINUITY_PROVIDER"

echo
echo "=== VERIFY SEMANTIC GENERATION CURRENT-TURN CONTRACT ==="
grep -n -A12 -B3 \
  'Set investigationLifecycle to null' \
  scripts/utils/ollamaChat.ts

echo
echo "=== TARGETED REGRESSION ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

npx tsx --test \
  server/matilda-interpretation-lifecycle-provider.test.ts

npx tsx --test \
  server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== CLASSIFICATION FINDINGS ==="
cat <<'FINDINGS'

Investigation Lifecycle continuity reconstruction classification:

1. Current-turn Investigation Lifecycle response generation is implemented.

2. Current-turn bounded lifecycle validation is implemented.

3. Direct workflow transport of the Matilda-authored lifecycle artifact to the
   IEL is implemented.

4. IEL persistence of the bounded lifecycle artifact is implemented.

5. Persisted Investigation Lifecycle state is stored in
   investigation_lifecycle_json.

6. No production read/reconstruction path currently deserializes persisted
   investigation_lifecycle_json into MatildaInvestigationLifecycleArtifact.

7. Persistence therefore does not currently establish cross-turn semantic
   Investigation Lifecycle continuity.

8. The existing matilda-interpretation-lifecycle-provider must not be treated
   as a semantic Investigation Lifecycle reconstruction provider merely because
   its name contains lifecycle.

9. Its current evidence does not establish reconstruction of:
   investigationIdentity,
   governingQuestion,
   lifecycleEvent,
   lifecycleDetermination.

10. Conversation Context Runtime remains lifecycle-independent.

11. selectedHistory does not currently carry the bounded Investigation
    Lifecycle semantic artifact.

12. Semantic generation therefore does not currently receive dedicated prior
    persisted Investigation Lifecycle state.

13. Cross-turn lifecycle continuity validation remains unavailable because its
    required prior semantic lifecycle input is unavailable.

14. Runtime must not manufacture that missing continuity by deriving lifecycle
    semantics from durableInterpretation, reply text, chronology,
    supersession_status, unresolved_questions, or other unrelated fields.

15. Matilda remains Interpretation Authority for semantic lifecycle facts.

16. Deterministic runtime may later deserialize, select, order, transport, and
    validate Matilda-authored lifecycle facts without becoming Interpretation
    Authority.

17. No second model invocation is required by the established architecture.

18. The narrowest unresolved prerequisite is the IEL lifecycle reconstruction
    read seam.

19. Reconstruction must be established before dedicated prior-lifecycle context
    transport can be classified.

20. Cross-turn transition validation must remain deferred until reconstruction
    and prior-context transport are independently established.

Capability state:

CURRENT_TURN_INVESTIGATION_LIFECYCLE_RESPONSE=IMPLEMENTED
CURRENT_TURN_INVESTIGATION_LIFECYCLE_VALIDATION=IMPLEMENTED
CURRENT_TURN_INVESTIGATION_LIFECYCLE_WORKFLOW_TRANSPORT=IMPLEMENTED
IEL_LIFECYCLE_PERSISTENCE=IMPLEMENTED

IEL_LIFECYCLE_RECONSTRUCTION=ABSENT
DEDICATED_PRIOR_LIFECYCLE_CONTEXT=ABSENT
SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=ABSENT
CROSS_TURN_CONTINUITY_VALIDATION=ABSENT

SECOND_MODEL_INVOCATION_REQUIRED=NO

PHASE_1_RESPONSE_COMPOSITION=CLOSED

Next corridor:

INVESTIGATE_INVESTIGATION_LIFECYCLE_IEL_RECONSTRUCTION_READ_SEAM

The next corridor is investigation only.

Do not implement reconstruction yet.

Do not add prior-lifecycle context yet.

Do not add cross-turn transition validation.

Do not modify current-turn lifecycle generation.

Do not modify current-turn workflow transport.

Do not modify IEL persistence.

Do not modify conversation-turn persistence.

Do not modify Living Draft behavior.

Do not modify Response Composition.

Do not change generation policy.

Do not add retries.

Do not add another model invocation.

Do not reopen Phase 1.

Preserve:

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

Preserve Matilda as Interpretation Authority.

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_CONTINUITY_RECONSTRUCTION_CURRENT_STATE_CLASSIFIED"
echo "CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH=IMPLEMENTED"
echo "IEL_LIFECYCLE_RECONSTRUCTION=ABSENT"
echo "DEDICATED_PRIOR_LIFECYCLE_CONTEXT=ABSENT"
echo "SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=ABSENT"
echo "CROSS_TURN_CONTINUITY_VALIDATION=ABSENT"
echo "SECOND_MODEL_INVOCATION_REQUIRED=NO"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_IEL_RECONSTRUCTION_READ_SEAM"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    db/matilda-interpretation-runtime.ts \
    db/matilda-conversation-runtime.ts \
    server/matilda-chat-workflow.ts \
    server/matilda-interpretation-lifecycle-provider.ts \
    server/matilda-conversation-context-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-continuity-reconstruction-current-state\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-investigation-lifecycle-continuity-reconstruction-current-state.sh
git diff --cached --check
git commit -m "Classify Investigation Lifecycle continuity reconstruction"
git push
