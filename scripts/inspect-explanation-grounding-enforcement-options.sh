#!/usr/bin/env bash
set -euo pipefail

echo "=== EXPLANATION GROUNDING — ENFORCEMENT OPTIONS ==="

echo
echo "=== VERIFIED FAILURE MODE ==="
cat <<'FINDING'
Behavior A is implemented and structurally valid.

Prompt-only grounding was behaviorally falsified.
The model generated unsupported engineering justification despite an explicit
instruction not to invent evidence or tradeoffs.

This investigation must not revisit prompt engineering.
FINDING

echo
echo "=== CURRENT EXPLANATION CONTRACT ==="
sed -n '225,250p' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT WORKFLOW SEAM ==="
sed -n '145,220p' server/matilda-chat-workflow.ts

echo
echo "=== CONVERSATION CONTEXT ==="
sed -n '1,220p' server/matilda-conversation-context-runtime.ts

echo
echo "=== PROJECT CONTEXT RETRIEVAL ==="
sed -n '1,220p' server/matilda-project-context-retrieval.ts

echo
echo "=== EXISTING FAIL-CLOSED PATTERNS ==="
rg -n -i -C 4 \
'fail.?closed|validate|validator|unsupported|authority|provenance|warning|reject' \
server scripts db \
--glob '!node_modules/**' \
--glob '!dist/**' \
| head -300 || true

echo
echo "=== INVESTIGATION ==="
cat <<'QUESTIONS'
The observed problem is:

Prompt compliance alone cannot guarantee grounded explanations.

Evaluate ONLY the following enforcement mechanisms.

A.
Pre-generation evidence sufficiency gate.

B.
Post-generation grounding validator.

C.
Structured evidence-binding contract.

D.
Combination, only if repository evidence demonstrates that
multiple mechanisms are actually necessary.

For each candidate determine:

1. Does the repository already contain most required information?
2. Can it operate deterministically?
3. Does it preserve one Ollama invocation?
4. Does it preserve Interpretation Authority?
5. Can failure degrade safely?
6. Can it be behaviorally validated?
7. What is the smallest implementation surface?
8. What evidence would falsify the candidate?

Classify each candidate:

IMPLEMENTATION_READY
DEFER
FALSIFIED

Do not redesign prompts.
Do not revisit Explanation Invitation.
Do not introduce another semantic author.
QUESTIONS

echo
echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
