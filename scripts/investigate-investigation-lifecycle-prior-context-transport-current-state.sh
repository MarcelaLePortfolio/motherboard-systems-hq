#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE INVESTIGATION LIFECYCLE PRIOR CONTEXT TRANSPORT CURRENT STATE ==="

REQUIRED_ANCESTOR="d54c9ab1"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: reconstruction classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY INVESTIGATION-ONLY STARTING SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-investigation-lifecycle-prior-context-transport-current-state\.sh$|^ M scripts/investigate-investigation-lifecycle-prior-context-transport-current-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_ONLY_STARTING_SURFACE_CONFIRMED"

echo
echo "=== VERIFY RECONSTRUCTION CLASSIFICATION ==="
grep -nE \
  'IEL_LIFECYCLE_RECONSTRUCTION=IMPLEMENTED|REUSABLE_BOUNDED_LIFECYCLE_VALIDATOR=IMPLEMENTED|DEDICATED_PRIOR_LIFECYCLE_CONTEXT=ABSENT|SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=ABSENT|CROSS_TURN_CONTINUITY_VALIDATION=ABSENT|NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_CURRENT_STATE' \
  scripts/classify-bounded-investigation-lifecycle-iel-reconstruction.sh

echo
echo "=== EXISTING IEL READ MODEL ==="
grep -n -A145 -B15 \
  'export type InterpretationEvidenceLedgerReadEntry' \
  db/matilda-interpretation-runtime.ts |
head -n 220

echo
echo "=== EXISTING IEL READER CALL SITES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  'listInterpretationEvidenceLedgerEntries' \
  db server scripts 2>/dev/null ||
true

echo
echo "=== CURRENT WORKFLOW CONTEXT ASSEMBLY ==="
grep -n -A260 -B40 \
  -E 'conversationContext|selectedHistory|ollamaChat|generateOllama|appendInterpretationEvidenceLedgerEntry' \
  server/matilda-chat-workflow.ts |
head -n 420

echo
echo "=== CONVERSATION CONTEXT RUNTIME ==="
sed -n '1,320p' \
  server/matilda-conversation-context-runtime.ts

echo
echo "=== INTERPRETATION CONTEXT RUNTIME ==="
sed -n '1,360p' \
  server/matilda-interpretation-context-runtime.ts

echo
echo "=== INTERPRETATION LIFECYCLE PROVIDER ==="
sed -n '1,320p' \
  server/matilda-interpretation-lifecycle-provider.ts

echo
echo "=== HISTORY SELECTION SURFACE ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E 'selectedHistory|historySelection|select.*History|ConversationContextRuntime|conversationContext' \
  server db scripts 2>/dev/null |
head -n 320 ||
true

echo
echo "=== PROJECT AND CONVERSATION SCOPING SURFACE ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E 'project_id|projectId|conversation_id|conversationId' \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-interpretation-context-runtime.ts \
  server/matilda-interpretation-lifecycle-provider.ts |
head -n 360 ||
true

echo
echo "=== LIFECYCLE IDENTITY / CHRONOLOGY SURFACE ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E 'investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination|created_at|ORDER BY|supersession_status' \
  db/matilda-interpretation-runtime.ts \
  server \
  scripts/utils/ollamaChat.ts 2>/dev/null |
head -n 420 ||
true

echo
echo "=== OLLAMA INPUT CONTRACT ==="
grep -n -A320 -B60 \
  -E 'export async function|selectedHistory|conversationContext|messages|prompt|fetch\(' \
  scripts/utils/ollamaChat.ts |
head -n 520

echo
echo "=== CURRENT LIFECYCLE PROMPT CONTRACT ==="
grep -n -A120 -B40 \
  -E 'investigationLifecycle|Investigation Lifecycle|investigation identity|governing question' \
  scripts/utils/ollamaChat.ts |
head -n 260

echo
echo "=== SEARCH FOR EXISTING PRIOR-LIFECYCLE TRANSPORT ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E 'prior.*investigation|previous.*investigation|prior.*lifecycle|previous.*lifecycle|investigationLifecycle|investigation_lifecycle_json' \
  server db scripts 2>/dev/null |
head -n 420 ||
true

echo
echo "=== SEARCH FOR EXISTING CONTEXT SEGMENT TYPES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E 'ContextSegment|context segment|selectedContextSegments|projectContextExcerpts|history:' \
  server scripts db 2>/dev/null |
head -n 360 ||
true

echo
echo "=== EXISTING CONTEXT / WORKFLOW TEST SURFACE ==="
find server scripts -maxdepth 3 -type f \
  \( -name '*context*.test.ts' \
     -o -name '*history*.test.ts' \
     -o -name '*workflow*.test.ts' \
     -o -name '*lifecycle*.test.ts' \) \
  -print |
sort

echo
echo "=== VERIFY CURRENT REGRESSION BASELINE ==="
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

bash scripts/guard-ollama-response-contract.sh

cat <<'FINDINGS'

Investigation questions requiring classification from repository evidence:

1. What production seam currently owns retrieval of historical semantic state?

2. Does the existing IEL reader provide sufficient project and conversation
   identity for bounded prior-lifecycle selection, or would its current global
   limit semantics make direct workflow use unsafe?

3. Is lifecycle candidate eligibility determined most safely by:
   - conversation scope,
   - project scope,
   - investigation identity,
   - chronology,
   - lifecycle event,
   - supersession state,
   - or a bounded combination of these?

4. Can one active prior lifecycle artifact be selected deterministically, or
   does the repository evidence require multiple prior artifacts?

5. Should prior lifecycle state become a field of Conversation Context Runtime,
   or should a narrower dedicated workflow/context seam own it?

6. Can selectedHistory remain strictly conversation-history-only?

7. What exact typed boundary can deliver prior lifecycle state to the existing
   single Ollama invocation without converting it into ordinary conversation
   prose?

8. What prompt representation would preserve the distinction between:
   - prior Matilda-authored lifecycle fact,
   - current user evidence,
   - current Matilda lifecycle determination?

9. How does Matilda remain Interpretation Authority for the current lifecycle
   event rather than having deterministic workflow logic author that event?

10. Which tests can prove:
    - correct project isolation,
    - correct conversation isolation,
    - correct lifecycle identity selection,
    - deterministic chronology,
    - no selectedHistory contamination,
    - no extra model invocation,
    - no semantic inference by workflow,
    - no mutation of reconstructed IEL facts?

11. What is the smallest rollback-safe implementation surface?

No implementation determination is made by this investigation unit.

Do not add prior-lifecycle context.

Do not alter Conversation Context Runtime.

Do not alter selectedHistory.

Do not alter semantic-generation inputs.

Do not alter the prompt.

Do not add transition validation.

Do not alter IEL persistence.

Do not alter IEL reconstruction.

Do not alter current-turn workflow transport.

Do not add retries.

Do not add another model invocation.

Do not reopen Phase 1 Response Composition.

Preserve:

Matilda
= Interpretation Authority and lifecycle semantic author

Workflow
= current-turn typed transport

IEL
= persistence and reconstruction owner

Shared validator
= deterministic enforcement of established lifecycle semantics

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_CURRENT_STATE_INSPECTED"
echo "IEL_LIFECYCLE_RECONSTRUCTION=IMPLEMENTED"
echo "PRIOR_CONTEXT_TRANSPORT_IMPLEMENTATION=NOT_STARTED"
echo "CROSS_TURN_CONTINUITY_VALIDATION=DEFERRED"
echo "PRODUCTION_RUNTIME_UNCHANGED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_BOUNDARY"

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
  echo "STOP: production runtime changed during investigation."
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

echo "PRODUCTION_RUNTIME_UNCHANGED_CONFIRMED"

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-investigation-lifecycle-prior-context-transport-current-state\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside investigation-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add \
  scripts/investigate-investigation-lifecycle-prior-context-transport-current-state.sh

git diff --cached --check
git commit -m "Investigate Investigation Lifecycle prior context transport"
git push
