#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE INVESTIGATION LIFECYCLE WORKFLOW CONSUMPTION SEAM ==="

REQUIRED_ANCESTOR="0a7caac9"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain response-implementation classification checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-investigation-lifecycle-workflow-consumption-seam\.sh$|^ M scripts/investigate-investigation-lifecycle-workflow-consumption-seam\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_INVESTIGATION_SCRIPT_ONLY"

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY RESPONSE REPRESENTATION COMPLETE ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_BOUNDED_RESPONSE_CONTRACT_IMPLEMENTED|INVESTIGATION_LIFECYCLE_RESPONSE_REPRESENTATION_COMPLETE|NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_SEAM' \
  scripts/classify-investigation-lifecycle-bounded-response-implementation.sh

echo
echo "=== CURRENT OLLAMA RESULT CONTRACT ==="
grep -n -A45 -B10 \
  -E 'interface OllamaChatResult|MatildaInvestigationLifecycleArtifact|investigationLifecycle' \
  scripts/utils/ollamaChat.ts | head -n 420

echo
echo "=== WORKFLOW OLLAMA INVOCATION AND RESULT CONSUMPTION ==="
grep -n -A150 -B45 \
  -E 'ollamaChat\(|durableInterpretation|result\.reply|reply:|createInterpretationEvidenceLedgerEntry|insertMatildaConversationTurn' \
  server/matilda-chat-workflow.ts | head -n 700

echo
echo "=== CONVERSATION CONTEXT RUNTIME ==="
sed -n '1,340p' \
  server/matilda-conversation-context-runtime.ts

echo
echo "=== CONVERSATION CONTEXT TYPE USAGE ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'ConversationContextRuntime|conversationContext|selectedHistory|interpretationLifecycleEntries|projectContextExcerpts' \
  server scripts db 2>/dev/null | head -n 700 || true

echo
echo "=== IEL WRITE CONTRACT ==="
grep -n -A130 -B30 \
  -E 'createInterpretationEvidenceLedgerEntry|InterpretationEvidenceLedger|unresolved_questions|lineage_references|supersession_status' \
  db/matilda-interpretation-runtime.ts | head -n 600

echo
echo "=== WORKFLOW IEL WRITE CALL ==="
grep -n -A90 -B30 \
  'createInterpretationEvidenceLedgerEntry' \
  server/matilda-chat-workflow.ts

echo
echo "=== CONVERSATION TURN PERSISTENCE ==="
grep -n -A80 -B30 \
  -E 'insertMatildaConversationTurn|createMatildaConversationTurn|conversation turn' \
  server/matilda-chat-workflow.ts \
  db/*.ts 2>/dev/null | head -n 600 || true

echo
echo "=== RESULT RETURN SURFACE ==="
tail -n 120 server/matilda-chat-workflow.ts

echo
echo "=== EXISTING EPHEMERAL OBSERVER / TRANSPORT PRECEDENTS ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'observeValidated|observer|validation-only|ephemeral|not persisted|not persist|transport' \
  server scripts/utils 2>/dev/null | head -n 700 || true

echo
echo "=== SERVER INVESTIGATION LIFECYCLE REFERENCES ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'investigationLifecycle' \
  server db routes 2>/dev/null || true

echo
echo "=== CONVERSATION CONTEXT INVESTIGATION-LIKE PRIMITIVES ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'supersessionStatus|authorityEvaluation|contaminationEvaluation|unresolved_questions|lineage_references' \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-chat-workflow.ts \
  db/matilda-interpretation-runtime.ts 2>/dev/null || true

cat <<'FINDINGS'

Investigation target:

Determine whether a legitimate workflow-consumption seam exists for the
already validated Matilda-authored investigationLifecycle artifact before
persistence or cross-turn continuity is designed.

Established state:

1. Investigation Lifecycle response representation is complete.

2. ollamaChat returns:

   investigationLifecycle:
     MatildaInvestigationLifecycleArtifact | null

3. The bounded artifact is validated fail-closed before OllamaChatResult is
   returned.

4. server/matilda-chat-workflow.ts currently does not consume
   investigationLifecycle.

5. No Investigation Lifecycle persistence exists.

6. No IEL extension exists.

7. No database change exists.

8. No cross-turn Investigation Lifecycle continuity validation exists.

9. Phase 1 Response Composition remains closed.

10. Conversation Engine Generation Stability remains deferred and separate.

Questions to resolve:

1. At what exact workflow statement is OllamaChatResult received?

2. Are reply and durableInterpretation destructured immediately, or is the
   complete result object retained?

3. Can investigationLifecycle be observed at that same boundary without
   altering semantic authorship?

4. Is there a legitimate current-turn consumer for investigationLifecycle?

5. If no legitimate consumer exists, would merely destructuring the artifact
   constitute meaningless plumbing rather than useful workflow consumption?

6. Does current workflow behavior require investigationLifecycle to influence:

   - reply transport;
   - IEL persistence;
   - conversation-turn persistence;
   - Living Draft update;
   - Conversation Context Runtime;
   - any other current-turn output?

7. If none of those surfaces has established Investigation Lifecycle semantics,
   should workflow consumption remain absent until the next required behavior
   is defined?

8. Could a validation-only observer analogous to existing selected-context or
   support observers prove workflow receipt without becoming production
   behavior?

9. Would such an observer answer an architectural question, or merely add test
   plumbing with no production value?

10. Does Conversation Context Runtime currently have a semantically appropriate
    place for Investigation Lifecycle facts?

11. Would adding investigationLifecycle to Conversation Context Runtime before
    persistence create only same-turn data that cannot exist on the next turn?

12. If so, is persistence necessarily upstream of useful cross-turn workflow
    consumption?

13. Can existing IEL lineage correlate investigations without storing the
    lifecycle artifact itself?

14. Does lifecycle continuity require prior Matilda-authored:

    investigationIdentity
    governingQuestion
    lifecycleEvent
    lifecycleDetermination

    to be available before the next Ollama invocation?

15. If prior lifecycle context is required, what repository-owned surface could
    legitimately supply it?

16. Is IEL the natural future persistence candidate, or does current IEL
    semantics make that premature?

17. Which component should eventually own deterministic transition validation:

    - ollamaChat parser;
    - matilda-chat-workflow;
    - Conversation Context Runtime;
    - dedicated lifecycle validation runtime;
    - another existing lifecycle evaluator?

18. Which component already has both:

    - the newly authored current lifecycle artifact;
    - the prior persisted lifecycle state

    or would naturally receive both once persistence exists?

19. Can workflow consumption be meaningfully implemented independently of
    persistence?

20. If not, the next corridor should investigate persistence/continuity
    ownership rather than adding empty workflow plumbing.

Required classification:

Exactly one of:

INVESTIGATION_LIFECYCLE_EPHEMERAL_WORKFLOW_CONSUMPTION_READY
INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_REQUIRES_PERSISTENCE_FIRST
INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_REQUIRES_CONTINUITY_CONTEXT_FIRST
INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_REQUIRES_DEDICATED_VALIDATION_SEAM
INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_NOT_YET_JUSTIFIED

Do not implement.

Do not edit ollamaChat.ts.

Do not edit server/matilda-chat-workflow.ts.

Do not edit Conversation Context Runtime.

Do not add observers.

Do not add persistence.

Do not extend IEL.

Do not change the database.

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
  echo "STOP: production runtime changed during workflow-consumption investigation."
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
  grep -vE '^scripts/investigate-investigation-lifecycle-workflow-consumption-seam\.sh$' ||
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

echo
echo "INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_EVIDENCE_COLLECTED"
echo "RESPONSE_REPRESENTATION_COMPLETE"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "PERSISTENCE_NOT_ADDED"
echo "IEL_EXTENSION_NOT_ADDED"
echo "DATABASE_CHANGE_NOT_ADDED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_SEAM"

git add \
  scripts/investigate-investigation-lifecycle-workflow-consumption-seam.sh
git diff --cached --check
git commit -m "Investigate Investigation Lifecycle workflow consumption seam"
git push
