#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE PRIOR CONTEXT TRANSPORT BOUNDARY ==="

REQUIRED_ANCESTOR="c047dfcb"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: prior-context transport investigation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-prior-context-transport-boundary\.sh$|^ M scripts/classify-investigation-lifecycle-prior-context-transport-boundary\.sh$' ||
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
grep -nE \
  'INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_CURRENT_STATE_INSPECTED|IEL_LIFECYCLE_RECONSTRUCTION=IMPLEMENTED|PRIOR_CONTEXT_TRANSPORT_IMPLEMENTATION=NOT_STARTED|CROSS_TURN_CONTINUITY_VALIDATION=DEFERRED|NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_BOUNDARY' \
  scripts/investigate-investigation-lifecycle-prior-context-transport-current-state.sh

echo
echo "=== VERIFY RECONSTRUCTED IEL READ MODEL ==="
grep -n -A125 -B10 \
  'export type InterpretationEvidenceLedgerReadEntry' \
  db/matilda-interpretation-runtime.ts |
head -n 190

echo
echo "=== VERIFY IEL READER CURRENT GLOBAL LIMIT / ORDERING ==="
grep -n -A85 -B10 \
  'export function listInterpretationEvidenceLedgerEntries' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY WORKFLOW CURRENT IEL RETRIEVAL ==="
grep -n -A60 -B30 \
  'listInterpretationEvidenceLedgerEntries(500)' \
  server/matilda-chat-workflow.ts

echo
echo "=== VERIFY WORKFLOW PROJECT / CONVERSATION FILTERING ==="
grep -n -A110 -B30 \
  -E 'project_id|conversation_id|conversationId|projectId|interpretationEntries' \
  server/matilda-chat-workflow.ts |
head -n 280

echo
echo "=== VERIFY CONVERSATION CONTEXT INPUT CONTRACT ==="
sed -n '1,120p' \
  server/matilda-conversation-context-runtime.ts

echo
echo "=== VERIFY SELECTED HISTORY CONTRACT ==="
cat server/matilda-history-selection-runtime.ts

echo
echo "=== VERIFY OLLAMA CONTEXT CURRENT SURFACE ==="
sed -n '195,275p' \
  scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY PRIOR LIFECYCLE INPUT ABSENT ==="
ollama_prior_refs="$(
  sed -n '195,275p' scripts/utils/ollamaChat.ts |
  grep -E 'prior.*Lifecycle|prior.*lifecycle|previous.*Lifecycle|previous.*lifecycle' ||
  true
)"

if [[ -n "$ollama_prior_refs" ]]; then
  echo "STOP: prior-lifecycle Ollama context already exists:"
  printf '%s\n' "$ollama_prior_refs"
  exit 2
fi

echo "PRIOR_LIFECYCLE_OLLAMA_INPUT_ABSENT"

echo
echo "=== VERIFY CONVERSATION CONTEXT LIFECYCLE FIELD ABSENT ==="
context_refs="$(
  grep -nE \
    'investigationLifecycle|investigation_lifecycle|investigationIdentity|governingQuestion|lifecycleDetermination' \
    server/matilda-conversation-context-runtime.ts ||
  true
)"

if [[ -n "$context_refs" ]]; then
  echo "STOP: Conversation Context Runtime already carries Investigation Lifecycle state:"
  printf '%s\n' "$context_refs"
  exit 2
fi

echo "CONVERSATION_CONTEXT_LIFECYCLE_FIELD_ABSENT"

echo
echo "=== VERIFY SELECTED HISTORY LIFECYCLE FIELD ABSENT ==="
history_refs="$(
  grep -R -n \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.sh' \
    -E 'selectedHistory.*(investigationLifecycle|investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination)|(investigationLifecycle|investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination).*selectedHistory' \
    server db scripts 2>/dev/null ||
  true
)"

if [[ -n "$history_refs" ]]; then
  echo "STOP: selectedHistory already carries lifecycle semantics:"
  printf '%s\n' "$history_refs"
  exit 2
fi

echo "SELECTED_HISTORY_LIFECYCLE_INDEPENDENCE_CONFIRMED"

echo
echo "=== VERIFY RECONSTRUCTED IEL ENTRY HAS REQUIRED SCOPE IDENTITY ==="
grep -nE \
  'project_id: string \| null|conversation_id: string \| null|investigationLifecycle: MatildaInvestigationLifecycleArtifact \| null|created_at: string|supersession_status: string' \
  db/matilda-interpretation-runtime.ts |
head -n 80

echo
echo "=== VERIFY CURRENT HISTORY WINDOW DOES NOT DEFINE LIFECYCLE ELIGIBILITY ==="
grep -n -A70 -B20 \
  'selectMatildaConversationHistory' \
  server/matilda-history-selection-runtime.ts

echo
echo "=== VERIFY CURRENT INTERPRETATION LIFECYCLE PROVIDER RESPONSIBILITY ==="
cat server/matilda-interpretation-lifecycle-provider.ts

echo
echo "=== VERIFY CURRENT COMPLETED CONTRACTS ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

npx tsx --test \
  server/matilda-interpretation-context-runtime.test.ts

npx tsx --test \
  server/matilda-interpretation-lifecycle-provider.test.ts

npx tsx --test \
  server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

cat <<'FINDINGS'

Classification:

INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_REQUIRES_DEDICATED_BOUNDED_SEAM

Repository-supported determination:

1. Current-turn Investigation Lifecycle generation, transport, persistence, and
   reconstruction are implemented.

2. Reconstructed IEL entries expose:

   project_id
   conversation_id
   created_at
   supersession_status
   investigationLifecycle

3. The production workflow already reads IEL entries through the established
   repository reader.

4. That reader remains globally limited and ordered by newest created_at first.

5. Therefore the raw global IEL reader result must not itself define semantic
   prior-lifecycle eligibility.

6. Prior lifecycle state must be scoped before semantic-generation transport.

7. Conversation identity is the narrowest already-established continuity
   boundary for Matilda conversation history.

8. Project identity alone is insufficient because it could admit lifecycle state
   belonging to another conversation.

9. Investigation identity alone is also insufficient because the runtime must
   first remain bounded to the current project/conversation authority corridor.

10. The minimum deterministic eligibility boundary is therefore:

    same project
    AND
    same conversation
    AND
    non-null reconstructed investigationLifecycle

11. Within that bounded set, lifecycle identity and chronology may be used to
    preserve authored continuity facts, but deterministic runtime must not
    author a new lifecycle event.

12. supersession_status is interpretation-authority metadata and must not be
    treated as a semantic Investigation Lifecycle event.

13. Conversation history chronology must remain independent from lifecycle
    semantic state.

14. selectedHistory must therefore remain conversation-history-only.

15. Prior lifecycle state should not be encoded as a synthetic conversation
    turn.

16. Prior lifecycle state should not be injected into project-context evidence.

17. Prior lifecycle state requires its own typed context channel.

18. Conversation Context Runtime is the existing workflow-owned composition
    object immediately before semantic generation, but adding lifecycle state
    there would broaden an already-established runtime boundary.

19. The smallest rollback-safe surface is therefore a narrower dedicated
    workflow-owned prior-lifecycle context seam assembled adjacent to existing
    conversationContext composition.

20. That seam should carry bounded reconstructed
    MatildaInvestigationLifecycleArtifact values without converting them to
    ordinary prose until the Ollama prompt boundary.

21. The initial transport contract should prefer one bounded active prior
    lifecycle artifact rather than an unbounded lifecycle history.

22. The selected prior artifact should be the newest eligible reconstructed
    lifecycle artifact within the current project and conversation.

23. Runtime selection of the newest eligible prior artifact is deterministic
    retrieval/transport behavior, not lifecycle interpretation.

24. Matilda remains Interpretation Authority for whether the current message:
    enters,
    continues,
    advances,
    resolves,
    supersedes,
    abandons,
    or does not participate in an investigation.

25. The prior lifecycle artifact is context, not an instruction to preserve its
    previous lifecycleEvent as the current event.

26. The prompt must explicitly distinguish:

    prior Matilda-authored lifecycle state

    from:

    current lifecycle determination to be authored by Matilda.

27. No second model invocation is required.

28. Cross-turn lifecycle transition validation remains deferred until this
    prior-context transport path is independently implemented and validated.

29. Conversation Context Runtime itself does not need modification if the
    dedicated seam can be passed alongside its existing fields at the workflow
    -> ollamaChat boundary.

30. selectedHistory does not require modification.

31. IEL persistence does not require modification.

32. IEL reconstruction does not require modification.

33. Conversation-turn persistence does not require modification.

34. Living Draft behavior does not require modification.

35. Phase 1 Response Composition remains closed.

Capability classification:

PRIOR_LIFECYCLE_ELIGIBILITY_SCOPE=SAME_PROJECT_AND_CONVERSATION

PRIOR_LIFECYCLE_REQUIRED_STATE=NON_NULL_RECONSTRUCTED_ARTIFACT

PRIOR_LIFECYCLE_SELECTION=NEWEST_ELIGIBLE_ARTIFACT

MULTIPLE_PRIOR_LIFECYCLE_ARTIFACTS=NOT_REQUIRED_FOR_INITIAL_BOUNDARY

SELECTED_HISTORY_ROLE=UNCHANGED_CONVERSATION_HISTORY_ONLY

CONVERSATION_CONTEXT_RUNTIME_CHANGE=NOT_REQUIRED

DEDICATED_PRIOR_LIFECYCLE_CONTEXT_SEAM=REQUIRED

OLLAMA_CONTEXT_EXTENSION=REQUIRED

PROMPT_BOUNDARY_EXTENSION=REQUIRED

SECOND_MODEL_INVOCATION_REQUIRED=NO

CROSS_TURN_TRANSITION_VALIDATION=DEFERRED

SEMANTIC_LIFECYCLE_AUTHOR=MATILDA

RUNTIME_ROLE=DETERMINISTIC_SCOPE_SELECTION_AND_TRANSPORT_ONLY

Smallest next unit:

CLASSIFY_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_IMPLEMENTATION_READINESS

That readiness unit must establish the exact smallest implementation surface
before production changes begin.

Candidate implementation surface to verify:

- server/matilda-chat-workflow.ts
  Select the newest eligible reconstructed lifecycle artifact from the existing
  IEL read result using current project and conversation identity.

- scripts/utils/ollamaChat.ts
  Add one typed nullable prior-lifecycle context input and serialize it as a
  separately labeled prior Matilda-authored lifecycle fact at the prompt
  boundary.

- narrow tests only
  Prove project/conversation isolation, newest eligible selection, exact
  transport, prompt separation, no selectedHistory contamination, no semantic
  mutation, and one invocation.

Do not implement this candidate surface in the present classification unit.

Do not modify Conversation Context Runtime.

Do not modify selectedHistory.

Do not create synthetic conversation turns.

Do not create a parallel IEL query.

Do not add lifecycle history arrays unless contradictory evidence requires them.

Do not implement transition validation.

Do not alter IEL persistence.

Do not alter IEL reconstruction.

Do not change generation policy.

Do not add retries.

Do not add another model invocation.

Do not reopen Phase 1.

Preserve:

Matilda
= Interpretation Authority and current lifecycle semantic author

Workflow
= deterministic prior-state scope selection and typed transport

IEL
= persistence and reconstruction owner

selectedHistory
= conversation-history selection only

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_BOUNDARY_CLASSIFIED"
echo "PRIOR_LIFECYCLE_ELIGIBILITY_SCOPE=SAME_PROJECT_AND_CONVERSATION"
echo "PRIOR_LIFECYCLE_REQUIRED_STATE=NON_NULL_RECONSTRUCTED_ARTIFACT"
echo "PRIOR_LIFECYCLE_SELECTION=NEWEST_ELIGIBLE_ARTIFACT"
echo "DEDICATED_PRIOR_LIFECYCLE_CONTEXT_SEAM=REQUIRED"
echo "SELECTED_HISTORY_ROLE=UNCHANGED"
echo "CONVERSATION_CONTEXT_RUNTIME_CHANGE=NOT_REQUIRED"
echo "OLLAMA_CONTEXT_EXTENSION=REQUIRED"
echo "PROMPT_BOUNDARY_EXTENSION=REQUIRED"
echo "SECOND_MODEL_INVOCATION_REQUIRED=NO"
echo "CROSS_TURN_CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=CLASSIFY_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_IMPLEMENTATION_READINESS"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  server/matilda-interpretation-context-runtime.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during prior-context classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    db/matilda-interpretation-runtime.ts \
    db/matilda-conversation-runtime.ts \
    server/matilda-chat-workflow.ts \
    server/matilda-interpretation-lifecycle-provider.ts \
    server/matilda-interpretation-context-runtime.ts \
    server/matilda-conversation-context-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-prior-context-transport-boundary\.sh$' ||
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
  scripts/classify-investigation-lifecycle-prior-context-transport-boundary.sh

git diff --cached --check
git commit -m "Classify Investigation Lifecycle prior context transport boundary"
git push
