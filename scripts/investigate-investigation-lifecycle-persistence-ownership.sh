#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE INVESTIGATION LIFECYCLE PERSISTENCE OWNERSHIP ==="

REQUIRED_ANCESTOR="bea81d78"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain persistence-first classification checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-investigation-lifecycle-persistence-ownership\.sh$|^ M scripts/investigate-investigation-lifecycle-persistence-ownership\.sh$' ||
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
echo "=== VERIFY PERSISTENCE-FIRST CLASSIFICATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_REQUIRES_PERSISTENCE_FIRST|PERSISTENCE_OWNER=UNDETERMINED|NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNERSHIP' \
  scripts/classify-investigation-lifecycle-workflow-consumption-seam.sh

echo
echo "=== INTERPRETATION EVIDENCE LEDGER MODEL ==="
grep -n -A120 -B20 \
  -E 'InterpretationEvidenceLedger|createInterpretationEvidenceLedgerEntry|listInterpretationEvidenceLedgerEntries|interpretation_event|matilda_observation|lineage_references|supersession_status' \
  db/matilda-interpretation-runtime.ts | head -n 700 || true

echo
echo "=== CONVERSATION TURN MODEL ==="
grep -n -A150 -B25 \
  -E 'MatildaConversationTurn|CreateMatildaConversationTurnInput|createMatildaConversationTurn|listMatildaConversationTurns|interpretation_entry_id|project_context_evidence_trace' \
  db/matilda-conversation-runtime.ts | head -n 900 || true

echo
echo "=== INTERPRETATION LIFECYCLE PROVIDER ==="
sed -n '1,320p' server/matilda-interpretation-lifecycle-provider.ts

echo
echo "=== CONVERSATION CONTEXT RUNTIME ==="
sed -n '1,260p' server/matilda-conversation-context-runtime.ts

echo
echo "=== WORKFLOW PERSISTENCE AND CONTEXT COMPOSITION ORDER ==="
sed -n '84,330p' server/matilda-chat-workflow.ts

echo
echo "=== DATABASE SCHEMA — RELEVANT TABLES ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'CREATE TABLE.*matilda|matilda_conversation_turns|interpretation_evidence|interpretation.*ledger|project_context_evidence_trace_json' \
  db server scripts 2>/dev/null | head -n 700 || true

echo
echo "=== LINEAGE AND CONVERSATION ISOLATION TESTS ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'lineage|cross-conversation|conversation_id|project_id|supersession|lifecycle' \
  db/*.test.ts server/*.test.ts scripts/*.test.ts scripts/utils/*.test.ts 2>/dev/null | head -n 1000 || true

echo
echo "=== EXISTING LIFECYCLE STATE / EVALUATOR SURFACES ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'lifecycle|authorityStatus|contamination|superseded|unresolved|eligible' \
  server db 2>/dev/null | head -n 1000 || true

echo
echo "=== INVESTIGATION LIFECYCLE CONTRACT REFERENCES ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'investigationLifecycle|investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination' \
  scripts server db 2>/dev/null | head -n 1000 || true

echo
echo "=== CURRENT IEL WRITE SITE ==="
grep -n -A75 -B15 \
  'createInterpretationEvidenceLedgerEntry' \
  server/matilda-chat-workflow.ts

echo
echo "=== CURRENT TURN WRITE SITE ==="
grep -n -A45 -B15 \
  'createMatildaConversationTurn' \
  server/matilda-chat-workflow.ts

echo
echo "=== CURRENT HISTORY / IEL READ SITES ==="
grep -n -A80 -B20 \
  -E 'listMatildaConversationTurns|listInterpretationEvidenceLedgerEntries|selectMatildaInterpretationLifecycleEntries|composeMatildaConversationContext' \
  server/matilda-chat-workflow.ts

cat <<'FINDINGS'

Investigation target:

Determine the smallest semantically correct persistence owner for the already
validated Matilda-authored Investigation Lifecycle artifact.

Established state:

1. Investigation Lifecycle response representation is complete.

2. Workflow consumption has been classified:

   INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_REQUIRES_PERSISTENCE_FIRST

3. Current lifecycle facts are Matilda-authored semantic facts:

   investigationIdentity
   governingQuestion
   lifecycleEvent
   lifecycleDetermination

4. Persistence ownership remains undetermined.

5. No persistence implementation is authorized by this investigation.

Candidate A — Interpretation Evidence Ledger:

Determine whether the IEL is semantically responsible for preserving Matilda's
interpretation facts across turns.

Inspect whether:

- one IEL entry already exists per semantic workflow;
- the entry is project and conversation scoped;
- it already carries Matilda-authored observation;
- lineage is already attached;
- lifecycle/supersession semantics already operate over IEL entries;
- prior IEL entries are already read before semantic generation;
- storing bounded lifecycle facts there would preserve semantic authorship
  without conflating them with evidence, unresolved questions, or generic
  supersession state.

Also determine whether adding explicit lifecycle facts to IEL would be a
natural schema extension or an architectural category error.

Candidate B — Conversation-turn persistence:

Determine whether the conversation turn is primarily a transport/history record
or whether it legitimately owns semantic lifecycle state.

Inspect whether:

- conversation turns already provide project/conversation isolation;
- they are retrieved as semantic history;
- they maintain lineage to the IEL entry;
- adding lifecycle state there would duplicate semantic facts already owned by
  interpretation persistence;
- lifecycle facts would become incorrectly coupled to assistant reply/history
  transport.

Candidate C — Dedicated Investigation Lifecycle persistence:

Determine whether lifecycle semantics require an independent state model.

A dedicated surface is justified only if repository evidence establishes that
lifecycle state:

- has an identity/lifetime distinct from an IEL entry;
- spans multiple interpretation entries;
- requires independent transition history;
- cannot be represented without distorting IEL or turn semantics;
- needs independent retrieval or mutation semantics.

Do not prefer a new table merely because lifecycle spans turns.

Candidate D — Existing interpretation lifecycle provider/runtime:

Determine whether the existing interpretation lifecycle provider already owns
the relevant concept of semantic lifecycle, or whether it only evaluates
authority/supersession eligibility for existing interpretation entries.

Do not conflate Investigation Lifecycle with Interpretation Lifecycle solely
because both use the word lifecycle.

Ownership questions:

1. Which existing persisted object is the authoritative record of Matilda's
   semantic interpretation for one workflow?

2. Which persisted object already survives across turns and is available before
   the next Ollama invocation?

3. Which object already carries project/conversation identity and lineage?

4. Does investigationLifecycle describe the current interpretation entry, or an
   investigation entity spanning multiple entries?

5. Is investigationIdentity stable across several IEL entries?

6. If it is stable across entries, can explicit lifecycle facts still live on
   each IEL entry as event history?

7. Would lifecycle facts on conversation turns duplicate semantic ownership?

8. Would lifecycle facts in a dedicated table duplicate IEL event history?

9. Can prior lifecycle state be reconstructed deterministically from ordered IEL
   entries if explicit lifecycle fields are persisted there?

10. Would that permit future continuity validation before semantic generation?

11. Does the existing lifecycle provider naturally receive those IEL entries?

12. Could a dedicated lifecycle validator later consume prior persisted
    lifecycle facts plus the current validated artifact without changing model
    authorship?

13. What schema change would each candidate require?

14. Which candidate has the smallest safe implementation surface?

15. Which candidate preserves rollback most cleanly?

16. Which candidate preserves:

    one user message
    -> one workflow
    -> one Ollama invocation
    -> one IEL entry
    -> one conversation turn
    -> one Living Draft update

17. Which candidate best preserves Matilda as Interpretation Authority?

Required classification:

Exactly one of:

INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNER_IEL
INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNER_CONVERSATION_TURN
INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNER_DEDICATED_RUNTIME
INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNER_EXISTING_LIFECYCLE_PROVIDER
INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNERSHIP_REQUIRES_MORE_EVIDENCE

If IEL is selected, additionally determine whether the likely representation is:

IEL_EXPLICIT_STRUCTURED_LIFECYCLE_FIELDS
IEL_BOUNDED_LIFECYCLE_JSON
IEL_REPRESENTATION_REQUIRES_SEPARATE_INVESTIGATION

Do not implement.

Do not edit ollamaChat.ts.

Do not edit server/matilda-chat-workflow.ts.

Do not edit Conversation Context Runtime.

Do not edit the interpretation lifecycle provider.

Do not extend IEL.

Do not change conversation-turn persistence.

Do not create a lifecycle table.

Do not change the database.

Do not add observers.

Do not add continuity validation.

Do not add lifecycle identity generation.

Do not infer lifecycle events.

Do not parse lifecycle semantics from durableInterpretation.

Do not repurpose unresolved_questions.

Do not repurpose supersession_status.

Do not add retries.

Do not add another model invocation.

Do not change generation policy.

Do not reopen Phase 1.

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
  server/matilda-conversation-context-runtime.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts
then
  echo "STOP: production runtime or persistence changed during ownership investigation."
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
  grep -vE '^scripts/investigate-investigation-lifecycle-persistence-ownership\.sh$' ||
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
echo "INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNERSHIP_EVIDENCE_COLLECTED"
echo "PERSISTENCE_OWNER=UNCLASSIFIED_PENDING_EVIDENCE_REVIEW"
echo "PERSISTENCE_NOT_ADDED"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNERSHIP"

git add scripts/investigate-investigation-lifecycle-persistence-ownership.sh
git diff --cached --check
git commit -m "Investigate Investigation Lifecycle persistence ownership"
git push
