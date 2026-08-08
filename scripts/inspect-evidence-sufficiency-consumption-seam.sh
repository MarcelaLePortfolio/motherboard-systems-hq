#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== EVIDENCE SUFFICIENCY — CONSUMPTION SEAM ==="

echo
echo "=== WORKFLOW RESULT CONSUMPTION ==="
sed -n '145,210p' server/matilda-chat-workflow.ts

echo
echo "=== EXPLANATION REQUEST CONTRACT ==="
rg -n -C 8 \
'explicitly asks why|requests an explanation|supporting evidence|walk through a recommendation|evidenceSufficient|explanationStatus' \
scripts/utils/ollamaChat.ts \
scripts/utils/ollamaChat.explanation-request.test.ts \
server \
--glob '!dist/**' \
--glob '!node_modules/**'

echo
echo "=== QUESTION ==="
cat <<'QUESTION'
Evidence Sufficiency now produces a deterministic boolean:

evidenceSufficient =
  validatedSupportSourceReferences.length > 0

Determine the smallest existing seam where that result can control explanation
behavior without:

- adding a second Ollama invocation;
- adding another semantic author;
- moving semantic explanation generation out of Ollama;
- changing Reasoning Composition;
- changing Evidence Composition;
- changing Boundary Composition;
- changing Adaptive Detail Selection.

Specifically determine:

1. Does the workflow already know whether the CURRENT user message is an explicit
   explanation request before calling Ollama?

2. Is there an existing deterministic explanation-request predicate?

3. If not, is explanation-request recognition currently owned only by Ollama
   prompt semantics?

4. Can evidenceSufficient safely be consumed before generation with the current
   architecture, or does that require one additional deterministic request signal?

Return exactly one classification:

IMPLEMENTATION_READY
NEEDS_EXPLANATION_REQUEST_SIGNAL
WRONG_SEAM

Do not implement a classifier.
Do not redesign the explanation response.
Do not modify runtime code.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
