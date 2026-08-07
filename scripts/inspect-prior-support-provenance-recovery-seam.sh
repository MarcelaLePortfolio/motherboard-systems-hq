#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== PRIOR SUPPORT PROVENANCE — RECOVERY SEAM ==="

echo
echo "=== IEL LIST RESULT SHAPE ==="
sed -n '300,380p' db/matilda-interpretation-runtime.ts

echo
echo "=== LIFECYCLE ENTRY SELECTION ==="
sed -n '1,240p' server/matilda-interpretation-lifecycle-provider.ts 2>/dev/null || true
rg -n -C 10 \
'selectMatildaInterpretationLifecycleEntries|interpretationEntryId|entry_id|supporting_raw_evidence' \
server \
db \
--glob '!dist/**' \
--glob '!node_modules/**' \
| head -320 || true

echo
echo "=== SELECTED HISTORY SHAPE ==="
sed -n '1,160p' server/matilda-conversation-history-context.ts
sed -n '1,160p' server/matilda-history-selection-runtime.ts

echo
echo "=== WORKFLOW PRE-OLLAMA SEAM ==="
sed -n '125,170p' server/matilda-chat-workflow.ts

echo
echo "=== EXPLANATION REQUEST SIGNAL ==="
cat server/matilda-explanation-request-signal.ts

echo
echo "=== PERSISTED SUPPORT READER ==="
cat server/matilda-support-provenance.ts

echo
echo "=== QUESTION ==="
cat <<'QUESTION'
Evidence Sufficiency remains open only until persisted prior-turn support
provenance can be recovered and consumed before the single Ollama invocation.

Determine the smallest deterministic recovery contract.

For an explicit explanation request:

1. Can the workflow use selectedHistory to identify the immediately preceding
   eligible assistant conclusion?

2. Does that selected history turn already carry interpretationEntryId?

3. Can that interpretationEntryId be matched directly to an existing IEL entry
   returned by listInterpretationEvidenceLedgerEntries()?

4. Can supporting_raw_evidence from that exact IEL entry be passed through
   readMatildaPersistedSupportProvenance() before ollamaChat()?

5. Should recovery inspect ONLY the immediately preceding selected history turn,
   rather than semantically searching older turns?

6. If the immediately preceding selected turn has:
   - persisted evidenceSufficient=true -> prior evidence is sufficient;
   - persisted evidenceSufficient=false -> prior evidence is insufficient;
   - no persisted provenance -> prior evidence sufficiency is unavailable.

7. Can this be represented deterministically without:
   - another model invocation;
   - semantic search;
   - changing history selection;
   - changing Interpretation Authority;
   - changing Reasoning Composition?

Return exactly one classification:

RECOVERY_IMPLEMENTATION_READY
NEEDS_NEW_LINEAGE_SIGNAL
WRONG_RECOVERY_MODEL

If RECOVERY_IMPLEMENTATION_READY, identify the smallest implementation unit
but do not implement it in this investigation.

Use repository evidence only.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
