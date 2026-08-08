#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== REASONING COMPOSITION — CURRENT STATE ==="

echo
echo "=== CURRENT REPLY CONTRACT ==="
sed -n '340,405p' scripts/utils/ollamaChat.ts

echo
echo "=== EXPLANATION / REASONING TESTS ==="
sed -n '1,220p' scripts/utils/ollamaChat.explanation-request.test.ts
sed -n '1,240p' scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts

echo
echo "=== REASONING-RELATED REPOSITORY EVIDENCE ==="
rg -n -C 6 \
'reasoning|engineering justification|explanation|tradeoff|supporting detail|hidden reasoning|chain-of-thought|explanationStatus' \
scripts/utils \
server \
docs/governance \
docs/architecture \
--glob '!dist/**' \
--glob '!node_modules/**' \
| head -420 || true

echo
echo "=== CURRENT RESPONSE CONSUMPTION ==="
rg -n -C 8 \
'ollamaResult.reply|conversationalReply|explanationStatus|priorExplanationEvidenceStatus' \
server/matilda-chat-workflow.ts \
scripts/utils/ollamaChat.ts

echo
echo "=== QUESTION ==="
cat <<'QUESTION'
Current active Response Composition corridor:

REASONING COMPOSITION

Evidence Sufficiency is CLOSED and now establishes whether a prior conclusion
may safely be justified.

Determine the exact existing capability state of Reasoning Composition.

Evaluate these questions:

1. Does the current semantic invocation already generate natural-language
   engineering justification for explicit explanation requests?

2. Is there a defined composition contract for WHAT a valid explanation should
   contain beyond generic grounding language?

3. Does the repository distinguish:
   - conclusion;
   - rationale;
   - tradeoffs;
   - architectural constraints;
   - uncertainty;
   - supporting evidence;
   or are these currently handled only as undifferentiated prose?

4. Is reasoning composition currently:
   - prompt-owned;
   - workflow-owned;
   - client-owned;
   - distributed?

5. Does the current contract define an ordered explanation structure, or only
   instruct the model to be concise and grounded?

6. Is explanationStatus involved in composing reasoning, or does it only
   classify disclosure priority?

7. Does Evidence Sufficiency now provide every deterministic prerequisite
   Reasoning Composition needs?

8. Are dedicated tests validating actual reasoning composition behavior, or
   only presence of prompt instructions and grounding constraints?

9. Can Reasoning Composition remain inside the existing single Ollama
   invocation without introducing another structured semantic artifact?

10. What is the smallest missing capability, if any?

Classify the corridor exactly as one of:

IMPLEMENTED_AND_VALIDATED
IMPLEMENTED_NOT_FULLY_VALIDATED
PARTIALLY_IMPLEMENTED
NOT_IMPLEMENTED
NEEDS_ARCHITECTURAL_RESCOPE

Then identify the smallest next implementation unit.

Do not modify Evidence Sufficiency.
Do not begin Evidence Composition.
Do not modify Boundary Composition.
Do not modify Adaptive Detail Selection.
Do not implement anything in this investigation.
Use repository evidence only.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
