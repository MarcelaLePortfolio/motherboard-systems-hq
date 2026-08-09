#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== BOUNDARY COMPOSITION — IMMATERIAL DISCLOSURE GAP ==="

echo
echo "=== CURRENT EVIDENCE LEDGER HARNESS ==="
cat scripts/capture-boundary-composition-evidence-ledger.ts

echo
echo "=== CURRENT RESPONSE CONTRACT ==="
sed -n '500,545p' scripts/utils/ollamaChat.ts

echo
echo "=== RELEVANT COMPOSITION TESTS ==="
cat scripts/utils/ollamaChat.summary-composition.test.ts
cat scripts/utils/ollamaChat.reasoning-composition.test.ts

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
Boundary Composition evidence-ledger validation produced five successful live
invocations.

Collaborative semantic review of those outputs found:

1. Material scope boundary:
   preserved.

2. Material unresolved uncertainty:
   preserved.

3. Authorization boundary:
   preserved.

4. Unsupported capability boundary:
   preserved.

5. Immaterial boundary:
   NOT omitted.
   The supplied excerpt was:
   "This test verifies duplicate support references are deterministically
   deduplicated. A future UI redesign is deferred."

   The user asked:
   "What does this test verify?"

   Matilda replied:
   "This test verifies that duplicate support references are deterministically
   deduplicated. A future UI redesign is deferred."

The deferred UI redesign did not affect the answer to the immediate question and
was mechanically surfaced.

Investigate this concrete gap only.

Determine from repository evidence:

1. Does the current Summary Composition contract already instruct Matilda to:
   - include only supporting detail needed for the current interaction;
   - avoid restating context unless it materially affects the response?

2. Does the current Boundary wording explicitly state that immaterial
   boundaries should be omitted, or only that material boundaries should be
   preserved?

3. Is the live failure therefore best classified as:
   a. existing prompt contract not reliably followed;
   b. missing bounded prompt instruction;
   c. need for deterministic filtering;
   d. need for structured Boundary state?

4. Can the smallest safe implementation remain inside the existing single
   semantic invocation?

5. Would adding a narrowly scoped instruction such as:
   "Do not surface boundaries, deferred work, or unresolved limits that do not
   materially affect the immediate conclusion or requested answer."
   resolve the observed gap without changing semantic ownership?

6. Would deterministic post-model filtering be unsafe because it would require
   semantic judgment about which natural-language boundary content is
   immaterial?

7. Does current evidence justify any new Boundary artifact, Boundary Status, or
   second model invocation?

Return exactly one classification:

BOUNDARY_COMPOSITION_BOUNDED_PROMPT_GAP
BOUNDARY_COMPOSITION_EXISTING_CONTRACT_RELIABILITY_GAP
BOUNDARY_COMPOSITION_DETERMINISTIC_FILTER_READY
BOUNDARY_COMPOSITION_STRUCTURED_BOUNDARY_READY
BOUNDARY_COMPOSITION_NOT_READY

Then identify exactly one smallest next unit.

Do not implement yet.
Do not modify Evidence Composition.
Do not add a second model invocation.
Do not begin Adaptive Detail Selection.
Preserve Matilda as semantic and Interpretation Authority.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
