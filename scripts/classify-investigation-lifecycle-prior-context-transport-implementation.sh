#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE PRIOR CONTEXT TRANSPORT IMPLEMENTATION ==="

REQUIRED_ANCESTOR="4c7512c9"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: prior-context implementation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-prior-context-transport-implementation\.sh$|^ M scripts/classify-investigation-lifecycle-prior-context-transport-implementation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY SCOPED IEL RETRIEVAL ==="
grep -n -A120 -B10 \
  'export interface ListInterpretationEvidenceLedgerEntriesOptions' \
  db/matilda-interpretation-runtime.ts |
head -n 190

echo
echo "=== VERIFY WORKFLOW SELECTION / TRANSPORT ==="
grep -n -A30 -B8 \
  'selectMatildaPriorInvestigationLifecycle' \
  server/matilda-chat-workflow.ts

grep -n -A35 -B12 \
  'scopedLifecycleLedgerEntries' \
  server/matilda-chat-workflow.ts

echo
echo "=== VERIFY OLLAMA PRIOR CONTEXT ==="
grep -n -A30 -B8 \
  'priorInvestigationLifecycle' \
  scripts/utils/ollamaChat.ts |
head -n 180

echo
echo "=== TARGETED REGRESSION ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-prior-context-transport.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

npx tsx --test \
  server/matilda-history-selection-runtime.test.ts

npx tsx --test \
  server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY ONE OLLAMA INVOCATION ==="
fetch_count="$(
  grep -c 'fetch(' scripts/utils/ollamaChat.ts ||
  true
)"

echo "OLLAMA_FETCH_REFERENCE_COUNT=$fetch_count"

[[ "$fetch_count" -eq 1 ]] || {
  echo "STOP: one Ollama invocation seam is not preserved."
  exit 2
}

echo "ONE_OLLAMA_INVOCATION_PRESERVED"

cat <<'FINDINGS'

Classification:

INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_IMPLEMENTED_AND_VALIDATED

Repository-supported determination:

1. IEL lifecycle persistence is implemented.

2. IEL lifecycle reconstruction is implemented.

3. The existing IEL reader supports bounded optional project/conversation
   scoping.

4. Scope is applied before ORDER BY and LIMIT.

5. Existing unscoped IEL-reader behavior remains available.

6. The workflow requests lifecycle candidates scoped to the current project and
   conversation.

7. The workflow selects the newest reconstructed non-null Investigation
   Lifecycle artifact from those scoped rows.

8. That selection is deterministic retrieval behavior only.

9. The workflow does not mutate, infer, repair, or author lifecycle semantic
   fields.

10. Matilda remains Interpretation Authority for current lifecycle semantics.

11. The selected prior artifact is transported unchanged through a dedicated
    nullable typed Ollama context field.

12. Prior lifecycle state remains independent from selectedHistory.

13. Prior lifecycle state is not encoded as a synthetic conversation turn.

14. Prior lifecycle state is not encoded as project-context evidence.

15. ollamaChat serializes prior lifecycle state at a dedicated prompt boundary.

16. The prompt explicitly separates prior Matilda-authored lifecycle state from
    the current lifecycle determination Matilda must author.

17. Conversation Context Runtime remains unchanged.

18. selectedHistory remains lifecycle-independent.

19. Conversation-turn persistence remains unchanged.

20. IEL persistence semantics remain unchanged.

21. IEL reconstruction semantics remain unchanged.

22. No database migration was introduced.

23. No historical backfill was introduced.

24. No parallel IEL query was introduced.

25. One Ollama invocation remains preserved.

26. Current lifecycle output schema remains unchanged.

27. Prior Investigation Lifecycle semantic context transport is therefore
    implemented and validated.

28. Cross-turn lifecycle transition validation remains absent.

29. Transition validation remains a separate downstream corridor.

Capability state:

CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH=IMPLEMENTED
IEL_LIFECYCLE_PERSISTENCE=IMPLEMENTED
IEL_LIFECYCLE_RECONSTRUCTION=IMPLEMENTED
PRIOR_LIFECYCLE_CONTEXT_TRANSPORT=IMPLEMENTED
SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=IMPLEMENTED

CROSS_TURN_TRANSITION_VALIDATION=ABSENT

SEMANTIC_LIFECYCLE_AUTHOR=MATILDA
RUNTIME_ROLE=DETERMINISTIC_SCOPE_SELECTION_AND_TRANSPORT_ONLY

SELECTED_HISTORY_ROLE=UNCHANGED
CONVERSATION_CONTEXT_RUNTIME_CHANGE=NONE
DATABASE_CHANGE=NONE
SECOND_MODEL_INVOCATION_REQUIRED=NO

PHASE_1_RESPONSE_COMPOSITION=CLOSED

Next canonical unit:

INVESTIGATE_INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_CURRENT_STATE

The next unit is investigation only.

Do not implement transition validation.

Do not alter prior-context transport.

Do not alter scoped IEL retrieval.

Do not alter IEL reconstruction.

Do not alter selectedHistory.

Do not alter Conversation Context Runtime.

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
echo "INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_IMPLEMENTED_AND_VALIDATED"
echo "PRIOR_LIFECYCLE_CONTEXT_TRANSPORT=IMPLEMENTED"
echo "SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=IMPLEMENTED"
echo "CROSS_TURN_TRANSITION_VALIDATION=ABSENT"
echo "SELECTED_HISTORY_ROLE=UNCHANGED"
echo "CONVERSATION_CONTEXT_RUNTIME_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_CURRENT_STATE"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED DURING CLASSIFICATION ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  server/matilda-interpretation-context-runtime.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-history-selection-runtime.ts
then
  echo "STOP: production runtime changed during classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-prior-context-transport-implementation\.sh$' ||
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

git add \
  scripts/classify-investigation-lifecycle-prior-context-transport-implementation.sh

git diff --cached --check
git commit -m "Classify Investigation Lifecycle prior context transport implementation"
git push
