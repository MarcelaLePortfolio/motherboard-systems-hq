#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE WORKFLOW CONSUMPTION SEAM ==="

REQUIRED_ANCESTOR="4842ffa1"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain workflow-consumption investigation checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-workflow-consumption-seam\.sh$|^ M scripts/classify-investigation-lifecycle-workflow-consumption-seam\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_CLASSIFICATION_SCRIPT_ONLY"

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY DEFINING INVESTIGATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_EVIDENCE_COLLECTED|RESPONSE_REPRESENTATION_COMPLETE|WORKFLOW_CONSUMPTION_NOT_ADDED|PERSISTENCE_NOT_ADDED|CONTINUITY_VALIDATION=DEFERRED|NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_SEAM' \
  scripts/investigate-investigation-lifecycle-workflow-consumption-seam.sh

echo
echo "=== VERIFY CURRENT WORKFLOW RESULT BOUNDARY ==="
grep -n -A30 -B10 \
  -E 'const ollamaResult|const conversationalReply|const durableInterpretation' \
  server/matilda-chat-workflow.ts

echo
echo "=== VERIFY CURRENT PERSISTENCE SURFACES ==="
grep -n -A70 -B10 \
  -E 'createInterpretationEvidenceLedgerEntry|createMatildaConversationTurn' \
  server/matilda-chat-workflow.ts | head -n 260

echo
echo "=== VERIFY NO SERVER LIFECYCLE CONSUMER ==="
server_refs="$(
  grep -Rni \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    'investigationLifecycle' \
    server db routes 2>/dev/null ||
  true
)"

if [[ -n "$server_refs" ]]; then
  echo "STOP: Investigation Lifecycle server/runtime references now exist and require reconciliation:"
  printf '%s\n' "$server_refs"
  exit 2
fi

echo "NO_INVESTIGATION_LIFECYCLE_SERVER_CONSUMER_CONFIRMED"

cat <<'FINDINGS'

Classification:

INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_REQUIRES_PERSISTENCE_FIRST

Repository-supported determination:

1. The bounded Matilda-authored investigationLifecycle response artifact is
   implemented and validated before OllamaChatResult is returned.

2. The complete ollamaResult reaches server/matilda-chat-workflow.ts.

3. The workflow currently consumes:

   - reply;
   - durableInterpretation;
   - supportSourceReferences;
   - evidenceSufficient.

4. The workflow does not currently consume investigationLifecycle.

5. No current production surface has established semantics requiring the
   investigationLifecycle artifact to affect:

   - the user-facing reply;
   - current IEL persistence;
   - conversation-turn persistence;
   - Living Draft synthesis;
   - Conversation Context Runtime;
   - authorization state.

6. Merely destructuring investigationLifecycle or adding a validation-only
   observer would prove transport but would not establish meaningful production
   workflow behavior.

7. Response transport is already proven by the typed OllamaChatResult contract.

8. Investigation Lifecycle is inherently cross-turn when it represents
   continuity such as:

   investigationIdentity
   governingQuestion
   lifecycleEvent
   lifecycleDetermination

9. A later semantic invocation cannot validate lifecycle continuity unless
   relevant prior Matilda-authored lifecycle facts survive the turn that
   authored them.

10. The current repository evidence shows no persistence of those facts.

11. Therefore useful cross-turn workflow consumption cannot yet be established
    independently of persistence.

12. This does not determine the persistence owner.

13. In particular, this classification does NOT establish that lifecycle facts
    belong in:

    - the Interpretation Evidence Ledger;
    - the conversation-turn record;
    - Conversation Context Runtime;
    - a new lifecycle table;
    - another persistence surface.

14. Persistence ownership must be investigated before implementation.

15. Continuity validation remains downstream of that ownership determination,
    because deterministic transition validation requires both current and prior
    lifecycle state.

16. The workflow is a likely future coordination seam because it receives the
    current validated artifact and already coordinates persistence operations,
    but repository evidence does not yet justify adding lifecycle behavior
    there.

17. No empty workflow plumbing should be introduced solely to mark the artifact
    as consumed.

18. No observer is required.

19. No production behavior changes are authorized by this classification.

20. The next canonical unit is:

    INVESTIGATE_INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNERSHIP

Required next investigation:

Determine the smallest semantically correct persistence surface capable of
preserving Matilda-authored Investigation Lifecycle facts across conversation
turns while preserving existing authority, lineage, conversation isolation,
and one-invocation invariants.

The investigation must compare at minimum:

- Interpretation Evidence Ledger;
- Matilda conversation-turn persistence;
- a dedicated Investigation Lifecycle persistence surface;
- any existing lifecycle repository/provider capable of owning these facts.

It must establish:

- ownership;
- identity and lineage requirements;
- project/conversation isolation;
- retrieval requirements;
- relationship to durableInterpretation;
- relationship to existing interpretation lifecycle state;
- whether schema/database changes are actually necessary;
- how prior lifecycle facts would eventually reach semantic generation;
- rollback and validation surfaces.

Do not implement persistence.

Do not edit ollamaChat.ts.

Do not edit server/matilda-chat-workflow.ts.

Do not edit Conversation Context Runtime.

Do not extend IEL.

Do not change conversation-turn persistence.

Do not create a lifecycle table.

Do not change the database.

Do not add observers.

Do not add cross-turn continuity validation.

Do not add lifecycle identity generation in runtime.

Do not infer lifecycle events.

Do not parse lifecycle semantics from durableInterpretation.

Do not repurpose unresolved_questions.

Do not repurpose supersession_status.

Do not add retries.

Do not add another model invocation.

Do not change generation policy.

Do not reopen Phase 1.

Do not reopen Adaptive Detail.

Do not reopen Evidence Composition.

Preserve:

one user message
-> one workflow
-> one Ollama invocation.

Preserve Matilda as Interpretation Authority.

FINDINGS

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during workflow-consumption classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts \
    server/matilda-conversation-context-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== PHASE 1 CLOSURE CONFIRMATION ==="
grep -n \
  'PHASE_1_RESPONSE_COMPOSITION_COMPLETE' \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-workflow-consumption-seam\.sh$' ||
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

echo
echo "INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_REQUIRES_PERSISTENCE_FIRST"
echo "RESPONSE_REPRESENTATION_COMPLETE"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "PERSISTENCE_NOT_ADDED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "PERSISTENCE_OWNER=UNDETERMINED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNERSHIP"

git add \
  scripts/classify-investigation-lifecycle-workflow-consumption-seam.sh
git diff --cached --check
git commit -m "Classify Investigation Lifecycle workflow consumption seam"
git push
