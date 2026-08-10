#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE PRIOR CONTEXT IMPLEMENTATION READINESS ==="

REQUIRED_ANCESTOR="66aa11ba"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: prior-context transport boundary checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY READINESS-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-prior-context-implementation-readiness\.sh$|^ M scripts/classify-investigation-lifecycle-prior-context-implementation-readiness\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "READINESS_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING TRANSPORT CLASSIFICATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_BOUNDARY_CLASSIFIED|PRIOR_LIFECYCLE_ELIGIBILITY_SCOPE=SAME_PROJECT_AND_CONVERSATION|PRIOR_LIFECYCLE_SELECTION=NEWEST_ELIGIBLE_ARTIFACT|DEDICATED_PRIOR_LIFECYCLE_CONTEXT_SEAM=REQUIRED|CONVERSATION_CONTEXT_RUNTIME_CHANGE=NOT_REQUIRED|OLLAMA_CONTEXT_EXTENSION=REQUIRED|PROMPT_BOUNDARY_EXTENSION=REQUIRED|NEXT_UNIT=CLASSIFY_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_IMPLEMENTATION_READINESS' \
  scripts/classify-investigation-lifecycle-prior-context-transport-boundary.sh

echo
echo "=== VERIFY EXISTING IEL READER ==="
grep -n -A110 -B10 \
  'export function listInterpretationEvidenceLedgerEntries' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY GLOBAL LIMIT PRECEDES WORKFLOW SCOPE SELECTION ==="
grep -n -A25 -B10 \
  'listInterpretationEvidenceLedgerEntries(500)' \
  server/matilda-chat-workflow.ts

echo
echo "=== VERIFY REQUIRED RECONSTRUCTED FIELDS ==="
grep -nE \
  'project_id: string \| null|conversation_id: string \| null|created_at: string|investigationLifecycle: MatildaInvestigationLifecycleArtifact \| null' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY WORKFLOW SCOPE IDENTITY ==="
grep -nE \
  'const projectId = input\.project_id\.trim|const conversationId|input\.conversation_id\.trim' \
  server/matilda-chat-workflow.ts

echo
echo "=== VERIFY SELECTED HISTORY REMAINS LIFECYCLE-INDEPENDENT ==="
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
  echo "STOP: selectedHistory lifecycle coupling exists:"
  printf '%s\n' "$history_refs"
  exit 2
fi

echo "SELECTED_HISTORY_INDEPENDENCE_CONFIRMED"

echo
echo "=== VERIFY CONVERSATION CONTEXT REMAINS LIFECYCLE-INDEPENDENT ==="
context_refs="$(
  grep -nE \
    'investigationLifecycle|investigationIdentity|governingQuestion|lifecycleDetermination' \
    server/matilda-conversation-context-runtime.ts ||
  true
)"

if [[ -n "$context_refs" ]]; then
  echo "STOP: Conversation Context Runtime lifecycle coupling exists:"
  printf '%s\n' "$context_refs"
  exit 2
fi

echo "CONVERSATION_CONTEXT_RUNTIME_INDEPENDENCE_CONFIRMED"

echo
echo "=== VERIFY OLLAMA CONTEXT EXTENSION SURFACE ==="
grep -n -A40 -B5 \
  'export interface OllamaChatContext' \
  scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY ONE MODEL INVOCATION ==="
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

echo
echo "=== VERIFY CURRENT REGRESSION BASELINE ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

npx tsx --test \
  server/matilda-conversation-context-runtime.test.ts

bash scripts/guard-ollama-response-contract.sh

cat <<'FINDINGS'

Implementation-readiness classification:

INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_IMPLEMENTATION_READY

Repository-supported implementation boundary:

1. Prior lifecycle eligibility remains:

   same project
   AND
   same conversation
   AND
   non-null reconstructed lifecycle artifact.

2. Prior lifecycle selection remains:

   newest eligible artifact.

3. The reconstructed IEL read model already carries the fields required for
   deterministic eligibility and selection.

4. The existing IEL reader is globally bounded before the workflow can apply
   project/conversation lifecycle eligibility.

5. Therefore filtering only the existing global 500-row result is insufficient
   for guaranteed cross-turn lifecycle continuity.

6. Increasing that global limit is not an acceptable substitute.

7. An unbounded read is not required.

8. A parallel lifecycle-specific IEL query is not required.

9. The smallest safe repository change is to extend the existing IEL reader
   with optional project/conversation scope parameters.

10. Scope must be applied before ORDER BY / LIMIT.

11. Existing unscoped reader behavior must remain available to existing callers.

12. The workflow may then request a bounded current-project/current-conversation
    IEL window and select the newest non-null reconstructed lifecycle artifact.

13. This selection is deterministic retrieval behavior only.

14. The workflow must not author, mutate, infer, or normalize lifecycle semantic
    facts.

15. Matilda remains Interpretation Authority for the current lifecycle event and
    determination.

16. selectedHistory remains unchanged.

17. Conversation Context Runtime remains unchanged.

18. The selected prior lifecycle artifact requires one dedicated nullable typed
    Ollama context field.

19. ollamaChat owns serialization of that prior artifact at the prompt boundary.

20. Prior lifecycle context must be explicitly separated from conversation
    history, project evidence, support provenance, and the current lifecycle
    output.

21. The prompt must identify the artifact as prior Matilda-authored semantic
    state that informs but does not dictate the current determination.

22. One Ollama invocation remains sufficient.

23. Current lifecycle output schema remains unchanged.

24. IEL persistence semantics remain unchanged.

25. IEL reconstruction semantics remain unchanged.

26. Conversation-turn persistence remains unchanged.

27. Living Draft behavior remains unchanged.

28. Cross-turn transition validation remains deferred until prior-context
    transport is independently implemented and validated.

29. Phase 1 Response Composition remains closed.

Authorized smallest implementation surface:

- db/matilda-interpretation-runtime.ts
- server/matilda-chat-workflow.ts
- scripts/utils/ollamaChat.ts
- narrow tests for scoped retrieval, selection, transport, prompt separation,
  authority preservation, and single invocation

Required validation:

- project isolation
- conversation isolation
- scoping before LIMIT
- existing unscoped reader compatibility
- newest eligible non-null selection
- null when no eligible lifecycle artifact exists
- exact typed transport without semantic mutation
- selectedHistory independence
- Conversation Context Runtime independence
- prior lifecycle not represented as conversation prose
- prior lifecycle not represented as project evidence
- prompt separation of prior state and current determination
- Matilda current-event authority preserved
- one Ollama invocation preserved
- current lifecycle response contract preserved
- IEL persistence and reconstruction regressions green

Not authorized:

- transition validation
- parallel IEL reader/query
- unbounded IEL retrieval
- global-limit inflation as a continuity fix
- selectedHistory modification
- Conversation Context Runtime modification
- synthetic conversation turns
- project-evidence lifecycle injection
- lifecycle response-schema redesign
- database migration
- historical backfill
- retries
- second model invocation
- Phase 1 reopening

NEXT_UNIT=IMPLEMENT_BOUNDED_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_IMPLEMENTATION_READINESS_CLASSIFIED"
echo "INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_IMPLEMENTATION_READY"
echo "SCOPED_IEL_RETRIEVAL_EXTENSION=REQUIRED"
echo "GLOBAL_500_FILTERING=INSUFFICIENT"
echo "PARALLEL_IEL_QUERY=PROHIBITED"
echo "UNBOUNDED_IEL_READ=PROHIBITED"
echo "PRIOR_LIFECYCLE_SELECTION=NEWEST_NON_NULL_WITHIN_SCOPED_ROWS"
echo "WORKFLOW_ROLE=DETERMINISTIC_SELECTION_AND_TYPED_TRANSPORT"
echo "OLLAMA_CONTEXT_EXTENSION=REQUIRED"
echo "PROMPT_BOUNDARY_EXTENSION=REQUIRED"
echo "SELECTED_HISTORY_CHANGE=NOT_REQUIRED"
echo "CONVERSATION_CONTEXT_RUNTIME_CHANGE=NOT_REQUIRED"
echo "DATABASE_CHANGE=NOT_REQUIRED"
echo "SECOND_MODEL_INVOCATION_REQUIRED=NO"
echo "CROSS_TURN_CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=IMPLEMENT_BOUNDED_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT"

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
  echo "STOP: production runtime changed during readiness classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY READINESS-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-prior-context-implementation-readiness\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside readiness-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "READINESS_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-investigation-lifecycle-prior-context-implementation-readiness.sh
git diff --cached --check
git commit -m "Classify Investigation Lifecycle prior context implementation readiness"
git push
