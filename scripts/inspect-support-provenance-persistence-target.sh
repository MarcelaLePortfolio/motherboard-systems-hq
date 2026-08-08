#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== SUPPORT PROVENANCE — PERSISTENCE TARGET REVIEW ==="

echo
echo "=== CONVERSATION TURN TYPE + STORAGE ==="
sed -n '1,150p' db/matilda-conversation-runtime.ts
sed -n '540,745p' db/matilda-conversation-runtime.ts

echo
echo "=== IEL TYPE + STORAGE ==="
sed -n '1,120p' db/matilda-interpretation-runtime.ts
sed -n '196,370p' db/matilda-interpretation-runtime.ts

echo
echo "=== HISTORY RECONSTRUCTION ==="
sed -n '1,180p' server/matilda-conversation-history-context.ts
sed -n '1,180p' server/matilda-history-selection-runtime.ts

echo
echo "=== WORKFLOW PERSISTENCE ORDER ==="
sed -n '150,245p' server/matilda-chat-workflow.ts

echo
echo "=== QUESTION ==="
cat <<'QUESTION'
The prior investigation established that supportSourceReferences and
evidenceSufficient from an original conclusion turn are not currently
recoverable by a later explanation request.

Determine the smallest architecturally correct persistence target.

Candidate A:
Persist support provenance directly on MatildaConversationTurn.

Candidate B:
Persist support provenance inside the existing IEL supporting_raw_evidence
payload and recover it through interpretation_entry_id lineage.

Candidate C:
Persist support provenance in both ConversationTurn and IEL.

Candidate D:
Create a new persistence subsystem.

For each candidate determine:

1. Which existing artifact semantically owns support provenance produced by the
   semantic interpretation invocation?

2. Does the candidate preserve the invariant that the workflow owns IEL
   persistence?

3. Does the candidate avoid duplicating authoritative state?

4. Can selectedHistory recover the original turn's support provenance
   deterministically through existing lineage?

5. Does the candidate require a schema migration?

6. Does the candidate introduce a new architectural boundary?

7. Can a later explicit explanation request access the original conclusion's
   validated support provenance before the next Ollama invocation?

8. Does it preserve one user message -> one workflow -> one Ollama invocation?

Return exactly one classification:

PERSIST_IN_IEL
PERSIST_ON_CONVERSATION_TURN
PERSIST_IN_BOTH
NEW_SUBSYSTEM_REQUIRED

Then identify the smallest next implementation unit.

Do not implement persistence.
Do not modify the Explanation Request Signal.
Do not modify Reasoning Composition.
Do not modify Evidence Composition.
Do not add another model invocation.
Use repository evidence only.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
