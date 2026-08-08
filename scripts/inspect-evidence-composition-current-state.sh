#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== EVIDENCE COMPOSITION — CURRENT STATE ==="

echo
echo "=== CURRENT REPLY + SUPPORT CONTRACT ==="
sed -n '350,410p' scripts/utils/ollamaChat.ts

echo
echo "=== SUPPORT PROVENANCE RUNTIME ==="
rg -n -C 8 \
'supportSourceReferences|evidenceSufficient|priorExplanationEvidenceStatus|support_source_references|evidence_sufficient' \
scripts/utils/ollamaChat.ts \
server/matilda-chat-workflow.ts \
server/matilda-support-provenance.ts \
server/matilda-prior-support-provenance.ts

echo
echo "=== CURRENT EVIDENCE-RELATED TESTS ==="
sed -n '1,460p' scripts/utils/ollamaChat.support-source-references.test.ts
sed -n '1,220p' scripts/utils/ollamaChat.support-source-production.test.ts
sed -n '1,220p' scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts

echo
echo "=== EVIDENCE PRESENTATION REFERENCES ==="
rg -n -C 6 \
'evidence presentation|present.*evidence|supporting evidence|source reference|support provenance|evidence inventory|cite|citation|source:' \
scripts \
server \
docs/governance \
docs/architecture \
--glob '!dist/**' \
--glob '!node_modules/**' \
| head -420 || true

echo
echo "=== CURRENT CLIENT / RESPONSE CONSUMPTION ==="
rg -n -C 8 \
'result.reply|reply: conversationalReply|supportSourceReferences|evidenceSufficient|assistant_reply' \
server \
routes \
src \
client \
--glob '!dist/**' \
--glob '!node_modules/**' \
2>/dev/null | head -360 || true

echo
echo "=== QUESTION ==="
cat <<'QUESTION'
Current active Response Composition corridor:

EVIDENCE COMPOSITION

Closed prerequisites:

- Summary Composition
- Evidence Sufficiency
- Reasoning Composition

The runtime already produces and validates supportSourceReferences, but the
user-visible reply is not yet known to compose or present that evidence.

Determine the exact existing capability state of Evidence Composition.

Evaluate:

1. Does Matilda currently present specific supporting evidence in the user-visible
   reply when evidence is available?

2. Is there an explicit prompt-owned Evidence Composition contract defining HOW
   evidence should be presented?

3. Does supportSourceReferences currently function only as provenance metadata,
   or does it directly control user-visible evidence wording?

4. Does the current system distinguish between:
   - conversation-turn support;
   - project-context excerpt support;
   when composing user-visible evidence?

5. Is there any rule requiring Matilda to connect a claim to the specific source
   that supports it?

6. Is there any rule preventing Evidence Composition from becoming a raw source
   dump or evidence inventory?

7. Is evidence presentation currently:
   - prompt-owned;
   - workflow-owned;
   - client-owned;
   - distributed;
   - absent?

8. Are there dedicated tests validating evidence presentation behavior rather
   than support-provenance production and validation?

9. Can Evidence Composition remain inside the existing reply field and existing
   single Ollama invocation without introducing another semantic artifact?

10. Does Evidence Sufficiency provide all deterministic prerequisites needed for
    Evidence Composition?

11. What is the smallest missing implementation unit?

Classify exactly one:

IMPLEMENTED_AND_VALIDATED
IMPLEMENTED_NOT_FULLY_VALIDATED
PARTIALLY_IMPLEMENTED
NOT_IMPLEMENTED
NEEDS_ARCHITECTURAL_RESCOPE

If implementation is needed, identify only the smallest next implementation
surface.

Do not modify Evidence Sufficiency.
Do not modify Reasoning Composition.
Do not begin Boundary Composition.
Do not begin Adaptive Detail Selection.
Do not implement anything in this investigation.
Use repository evidence only.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
