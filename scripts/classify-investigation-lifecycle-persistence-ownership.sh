#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE PERSISTENCE OWNERSHIP ==="

REQUIRED_ANCESTOR="484afe6d"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain persistence-ownership investigation checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-persistence-ownership\.sh$|^ M scripts/classify-investigation-lifecycle-persistence-ownership\.sh$' ||
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
  'INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNERSHIP_EVIDENCE_COLLECTED|PERSISTENCE_OWNER=UNCLASSIFIED_PENDING_EVIDENCE_REVIEW|NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNERSHIP' \
  scripts/investigate-investigation-lifecycle-persistence-ownership.sh

echo
echo "=== VERIFY IEL SEMANTIC OWNERSHIP SURFACE ==="
grep -n -A70 -B20 \
  -E 'createInterpretationEvidenceLedgerEntry|matilda_observation|lineage_references|supersession_status|conversation_id|project_id' \
  server/matilda-chat-workflow.ts | head -n 500

echo
echo "=== VERIFY PRIOR IEL READ BEFORE SEMANTIC GENERATION ==="
grep -n -A65 -B15 \
  -E 'listInterpretationEvidenceLedgerEntries|selectMatildaInterpretationLifecycleEntries|composeMatildaConversationContext|await ollamaChat' \
  server/matilda-chat-workflow.ts | head -n 600

echo
echo "=== VERIFY CONVERSATION TURN REMAINS HISTORY TRANSPORT ==="
grep -n -A55 -B15 \
  -E 'createMatildaConversationTurn|user_message|assistant_reply|interpretation_entry_id|project_context_retrieval' \
  server/matilda-chat-workflow.ts | head -n 400

echo
echo "=== VERIFY INVESTIGATION IDENTITY IS SEMANTIC IDENTITY ==="
grep -nE \
  'investigationIdentity is semantic identity|investigationIdentity.*semantic identity|Runtime must not.*investigationIdentity|conversation identifiers.*investigationIdentity|interpretation-entry identifiers.*investigationIdentity' \
  scripts/classify-investigation-lifecycle-semantic-fact-representation.sh \
  scripts/classify-investigation-lifecycle-structured-response-implementation-readiness.sh \
  scripts/implement-investigation-lifecycle-bounded-structured-response-contract.sh || true

echo
echo "=== VERIFY EXISTING INTERPRETATION LIFECYCLE PROVIDER ROLE ==="
sed -n '1,320p' server/matilda-interpretation-lifecycle-provider.ts

cat <<'FINDINGS'

Classification:

INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNER_IEL

Representation determination:

IEL_REPRESENTATION_REQUIRES_SEPARATE_INVESTIGATION

Repository-supported determination:

1. Investigation Lifecycle facts are Matilda-authored semantic interpretation
   facts, not conversation transport metadata and not deterministic runtime
   inventions.

2. The Interpretation Evidence Ledger is already the authoritative durable
   persistence surface for Matilda's semantic interpretation produced by one
   workflow.

3. The existing workflow creates one IEL entry for the semantic workflow and
   stores Matilda's durable observation on that entry.

4. IEL entries already carry:

   - project identity;
   - conversation identity;
   - interpretation-entry identity;
   - Matilda-authored observation;
   - lineage references;
   - interpretation supersession state.

5. Prior IEL entries already survive across turns and are read before the next
   semantic generation invocation.

6. The existing interpretation lifecycle provider already receives persisted
   IEL entries selected through conversation-turn interpretation-entry lineage.

7. Therefore IEL persistence provides the existing durable semantic path needed
   for future Investigation Lifecycle continuity without creating a second
   semantic ownership system.

8. Conversation-turn persistence is not the correct owner.

9. Conversation turns currently own conversational history transport:

   - user message;
   - assistant reply;
   - interpretation-entry linkage;
   - project-context retrieval trace.

10. Persisting Investigation Lifecycle semantic facts directly on conversation
    turns would duplicate semantic ownership already represented by the IEL and
    would couple Matilda-authored investigation semantics to conversational
    transport.

11. A dedicated Investigation Lifecycle table/runtime is not justified by the
    current evidence.

12. investigationIdentity can span multiple interpretation entries, but that
    does not itself require an independently persisted investigation entity.

13. Each IEL entry can naturally represent one Matilda-authored lifecycle event
    in an investigation's event history while preserving the same semantic
    investigationIdentity across entries.

14. Ordered IEL entries can therefore potentially reconstruct prior
    Investigation Lifecycle state deterministically once explicit lifecycle
    facts are persisted.

15. The existing interpretation lifecycle provider is not itself the
    persistence owner.

16. Its current responsibility concerns interpretation-entry lifecycle,
    authority, supersession, and eligibility.

17. Investigation Lifecycle and Interpretation Lifecycle remain distinct
    semantic concepts.

18. The provider may later become a retrieval or continuity-composition seam,
    but repository evidence does not justify redefining it as the persistence
    owner.

19. The smallest semantically correct persistence owner is therefore:

    INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNER_IEL

20. This classification does not authorize an IEL implementation yet.

21. The exact IEL representation is not established by persistence ownership
    alone.

22. In particular, repository evidence gathered so far does not establish
    whether the bounded lifecycle artifact should be represented as:

    - explicit structured IEL columns;
    - one bounded lifecycle JSON field;
    - another explicit representation preserving the same semantic ownership.

23. Existing generic fields must not be repurposed.

24. investigationIdentity must not be encoded into lineage_references merely
    because lineage exists.

25. lifecycleEvent must not be encoded into supersession_status.

26. lifecycleDetermination must not be encoded into unresolved_questions.

27. The current durableInterpretation string must not be parsed later to recover
    lifecycle facts.

28. Therefore the representation classification is:

    IEL_REPRESENTATION_REQUIRES_SEPARATE_INVESTIGATION

29. The next canonical unit is:

    INVESTIGATE_INVESTIGATION_LIFECYCLE_IEL_REPRESENTATION

Required next investigation:

Determine the smallest explicit IEL representation that preserves the complete
validated Matilda-authored artifact:

investigationIdentity
governingQuestion
lifecycleEvent
lifecycleDetermination

Compare at minimum:

A. Explicit structured IEL lifecycle columns.

B. One nullable bounded Investigation Lifecycle JSON field.

The investigation must establish:

- compatibility with the existing IEL schema;
- whether migrations are required;
- whether nullable representation preserves ordinary non-investigation turns;
- whether the four facts remain atomically associated;
- typed read/write behavior;
- project/conversation isolation;
- lineage behavior;
- ordered lifecycle reconstruction;
- compatibility with current interpretation lifecycle selection;
- future continuity-validation retrieval;
- rollback surface;
- migration/backfill behavior for historical IEL entries;
- whether old entries safely represent investigationLifecycle:null;
- test surface;
- smallest safe implementation surface.

Do not implement IEL persistence.

Do not edit ollamaChat.ts.

Do not edit server/matilda-chat-workflow.ts.

Do not edit Conversation Context Runtime.

Do not edit the interpretation lifecycle provider.

Do not change db/matilda-interpretation-runtime.ts.

Do not alter the database.

Do not add columns.

Do not add JSON persistence.

Do not create a lifecycle table.

Do not change conversation-turn persistence.

Do not add workflow consumption.

Do not add continuity validation.

Do not generate lifecycle identity deterministically.

Do not infer lifecycle events.

Do not parse lifecycle semantics from durableInterpretation.

Do not repurpose unresolved_questions.

Do not repurpose supersession_status.

Do not add retries.

Do not add another model invocation.

Do not change generation policy.

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
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION AND PERSISTENCE RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts
then
  echo "STOP: production runtime or persistence changed during ownership classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts \
    server/matilda-conversation-context-runtime.ts \
    server/matilda-interpretation-lifecycle-provider.ts \
    db/matilda-interpretation-runtime.ts \
    db/matilda-conversation-runtime.ts
  exit 2
fi

echo "PRODUCTION_AND_PERSISTENCE_RUNTIME_UNCHANGED"

echo
echo "=== PHASE 1 CLOSURE CONFIRMATION ==="
grep -n \
  'PHASE_1_RESPONSE_COMPOSITION_COMPLETE' \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-persistence-ownership\.sh$' ||
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
echo "INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNER_IEL"
echo "IEL_REPRESENTATION_REQUIRES_SEPARATE_INVESTIGATION"
echo "CONVERSATION_TURN_NOT_PERSISTENCE_OWNER"
echo "DEDICATED_LIFECYCLE_RUNTIME_NOT_JUSTIFIED"
echo "INTERPRETATION_LIFECYCLE_PROVIDER_NOT_PERSISTENCE_OWNER"
echo "PERSISTENCE_NOT_ADDED"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_IEL_REPRESENTATION"

git add scripts/classify-investigation-lifecycle-persistence-ownership.sh
git diff --cached --check
git commit -m "Classify Investigation Lifecycle persistence ownership"
git push
