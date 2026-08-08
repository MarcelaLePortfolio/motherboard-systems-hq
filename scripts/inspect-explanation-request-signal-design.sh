#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== EXPLANATION REQUEST SIGNAL — DESIGN INVESTIGATION ==="

echo
echo "=== EXISTING MESSAGE CLASSIFICATION / PREDICATE PATTERNS ==="
rg -n -C 5 \
'is[A-Z].*Request|request.*predicate|classif|intent.*detect|message.*match|explicit.*request|startsWith|includes\(|\.test\(' \
server \
scripts \
db \
--glob '!dist/**' \
--glob '!node_modules/**' \
--glob '!*.test.ts' \
| head -320 || true

echo
echo "=== CURRENT EXPLANATION SEMANTICS ==="
rg -n -C 10 \
'explicitly asks why|requests an explanation|supporting evidence|walk through a recommendation|engineering justification' \
scripts/utils/ollamaChat.ts \
scripts/utils/ollamaChat.explanation-request.test.ts

echo
echo "=== CURRENT EVIDENCE SUFFICIENCY RESULT ==="
rg -n -C 10 \
'evidenceSufficient|supportSourceReferences' \
scripts/utils/ollamaChat.ts \
server/matilda-chat-workflow.ts

echo
echo "=== QUESTION ==="
cat <<'QUESTION'
Evidence Sufficiency remains OPEN because its deterministic result is computed
but not yet consumed by explanation behavior.

The missing prerequisite is an Explanation Request Signal.

Determine whether that signal can safely be deterministic.

The signal must answer only:

"Is the current user message explicitly requesting explanation of a prior
conclusion, recommendation, assessment, evidence basis, or tradeoff?"

It must NOT determine:

- whether the requested explanation is valid;
- whether evidence exists;
- what the explanation should say;
- what reasoning is correct;
- user intent beyond the explicit request;
- confidence;
- semantic interpretation of ambiguous language.

Evaluate these candidate approaches:

A. Exact bounded phrase/pattern predicate over explicit request language.

B. General natural-language semantic classifier.

C. New structured signal authored by Ollama.

D. No separate signal; Evidence Sufficiency cannot safely control explanation
   behavior under the one-invocation architecture.

For each candidate determine:

1. Is it deterministic?
2. Does it preserve User Intent Authority?
3. Does it preserve Matilda Interpretation Authority?
4. Does it avoid becoming a second semantic author?
5. Can it exist before the single Ollama invocation?
6. Can it safely gate only the narrow Evidence Sufficiency behavior?
7. Can false negatives safely fall back to ordinary conversation behavior?
8. Can false positives cause semantic or architectural harm?

Return exactly one classification:

BOUNDED_DETERMINISTIC_SIGNAL_READY
SEMANTIC_SIGNAL_REQUIRED
EVIDENCE_SUFFICIENCY_CANNOT_PRE-GATE

If BOUNDED_DETERMINISTIC_SIGNAL_READY, identify the narrowest safe predicate
contract but DO NOT implement it.

Do not redesign Reasoning Composition.
Do not redesign Evidence Composition.
Do not modify the prompt.
Do not add another model invocation.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
