#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== PRIOR-TURN SUPPORT PROVENANCE — PERSISTENCE INVESTIGATION ==="

echo
echo "=== OLLAMA RESULT CONSUMPTION ==="
rg -n -C 12 \
'ollamaResult|supportSourceReferences|evidenceSufficient|durableInterpretation|conversationalReply' \
server/matilda-chat-workflow.ts \
db \
server \
--glob '!dist/**' \
--glob '!node_modules/**' \
| head -360 || true

echo
echo "=== CONVERSATION TURN PERSISTENCE SHAPE ==="
rg -n -C 10 \
'interface MatildaConversationTurn|assistant_reply|interpretation_entry_id|insert.*conversation|create.*conversation.*turn|persist.*turn' \
db/matilda-conversation-runtime.ts \
server \
--glob '!dist/**' \
--glob '!node_modules/**' \
| head -320 || true

echo
echo "=== IEL PERSISTENCE SHAPE ==="
rg -n -C 12 \
'createInterpretationEvidenceLedgerEntry|supporting_raw_evidence|minimum_sufficient_context|interpretation_event' \
server/matilda-chat-workflow.ts \
db \
--glob '!dist/**' \
--glob '!node_modules/**' \
| head -320 || true

echo
echo "=== SUPPORT PROVENANCE REFERENCES ==="
rg -n -C 8 \
'supportSourceReferences|evidenceSufficient' \
. \
--glob '!dist/**' \
--glob '!node_modules/**' \
--glob '!_PRE_RESTORE_BROKEN_STATE/**' \
--glob '!files/**' \
| head -360 || true

echo
echo "=== INVESTIGATION QUESTION ==="
cat <<'QUESTION'
Evidence Sufficiency is intended to control an explicit follow-up request asking
for explanation of a PRIOR conclusion, recommendation, assessment, evidence
basis, or tradeoff.

The repository now has:

- a bounded deterministic Explanation Request Signal;
- supportSourceReferences produced by the semantic invocation;
- exact-invocation membership validation;
- deterministic deduplication;
- evidenceSufficient derived from validated references.

Determine whether the support provenance needed by a later explanation request
survives beyond the ORIGINAL conclusion turn.

Answer these questions:

1. Are supportSourceReferences from the original turn persisted anywhere?

2. Is evidenceSufficient from the original turn persisted anywhere?

3. Can a later conversation-history entry recover the support provenance of the
   prior assistant conclusion?

4. Does selectedHistory contain only:
   - sourceTurnId
   - userMessage
   - assistantReply
   plus authority/contamination metadata,
   or does it also contain support provenance?

5. Would gating a follow-up explanation request using evidenceSufficient computed
   from the CURRENT explanation turn be temporally wrong because the value is only
   derived after that explanation has already been generated?

6. If prior-turn provenance is not persisted, is the next smallest missing unit:
   PERSIST_PRIOR_TURN_SUPPORT_PROVENANCE?

Return exactly one classification:

READY_TO_WIRE_EXPLANATION_GATE
NEEDS_PRIOR_TURN_PROVENANCE_PERSISTENCE
CURRENT_EVIDENCE_SUFFICIENCY_MODEL_IS_TEMPORALLY_WRONG

Do not implement persistence.
Do not redesign Reasoning Composition.
Do not modify the Explanation Request Signal.
Do not modify the prompt.
Do not add another model invocation.

Use repository evidence only.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
