#!/usr/bin/env bash
set -euo pipefail

echo "=== SUPPORT SIGNAL SHAPE INVESTIGATION ==="

echo
cat <<'QUESTION'
The origin has been established:

The signal must originate during the original semantic generation.

The remaining question is:

What is the MINIMUM structured signal that allows deterministic validation
without introducing another semantic author?

Evaluate these candidate shapes.

A.
supportAvailable: boolean

B.
supportSourceReferences:
- conversation turn identifiers
- project context excerpt identifiers

C.
supportAvailable + supportSourceReferences

D.
supportClassification
(values such as direct, inferred, mixed)

For each candidate determine:

1. Can deterministic runtime code validate it?
2. Does it avoid storing explanation prose?
3. Does it avoid storing chain-of-thought?
4. Does it preserve one Ollama invocation?
5. Does it preserve Interpretation Authority?
6. Can the future Evidence Sufficiency Gate consume it directly?
7. Is it the smallest sufficient contract?

Classify each:

IMPLEMENTATION_READY
TOO_WEAK
TOO_COMPLEX

Do not design implementation.
Do not redesign the prompt.
Do not revisit Explanation Invitation.
Determine only the minimum structured contract.
QUESTION

echo
echo "=== CURRENT RESPONSE CONTRACT ==="
sed -n '1,160p' scripts/utils/ollamaChat.ts

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
