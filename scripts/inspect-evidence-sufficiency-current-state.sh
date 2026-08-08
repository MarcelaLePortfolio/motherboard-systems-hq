#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== EVIDENCE SUFFICIENCY — CURRENT STATE ==="

echo
echo "=== SUPPORT REFERENCE RESPONSE CONTRACT ==="
sed -n '15,260p' scripts/utils/ollamaChat.ts

echo
echo "=== SUPPORT REFERENCE PROMPT INSTRUCTIONS ==="
rg -n -C 8 \
'supportSourceReferences|Conversation source:|Bounded project context evidence' \
scripts/utils/ollamaChat.ts

echo
echo "=== WORKFLOW CONSUMPTION ==="
rg -n -C 10 \
'ollamaResult|supportSourceReferences|selectedHistory|projectContextExcerpts' \
server/matilda-chat-workflow.ts

echo
echo "=== SUPPORT REFERENCE TEST COVERAGE ==="
sed -n '1,240p' scripts/utils/ollamaChat.support-source-references.test.ts

echo
echo "=== EVIDENCE SUFFICIENCY QUESTION ==="
cat <<'QUESTION'
Current active Response Composition corridor:

EVIDENCE SUFFICIENCY

Determine the exact implementation state of these sub-capabilities:

1. Stable conversation-source identifiers are supplied to Ollama.
2. Stable project-context identifiers are supplied to Ollama.
3. Ollama is explicitly instructed to populate supportSourceReferences.
4. Returned support references are structurally validated.
5. Returned conversation references are validated against the exact
   selectedHistory supplied to this invocation.
6. Returned project-context references are validated against the exact
   projectContextExcerpts supplied to this invocation.
7. Duplicate references are handled deterministically.
8. A deterministic evidence-sufficiency result is derived from the validated
   reference set.
9. Explanation-request behavior consumes that evidence-sufficiency result.
10. Dedicated behavioral validation proves both:
    - supported prior conclusions may be explained;
    - unsupported prior conclusions fail safely without invented justification.

Classify each item exactly as:

IMPLEMENTED_AND_VALIDATED
IMPLEMENTED_NOT_VALIDATED
NOT_IMPLEMENTED

Then identify the smallest next implementation unit.

Do not redesign Reasoning Composition.
Do not implement Evidence Composition.
Do not modify Boundary Composition.
Do not modify Adaptive Detail Selection.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
