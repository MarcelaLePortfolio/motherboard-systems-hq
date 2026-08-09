#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== BOUNDARY COMPOSITION — CURRENT STATE INVESTIGATION ==="

echo
echo "=== RESPONSE COMPOSITION CONTRACT ==="
sed -n '480,545p' scripts/utils/ollamaChat.ts

echo
echo "=== STRUCTURED RESPONSE TYPES ==="
sed -n '140,180p' scripts/utils/ollamaChat.ts

echo
echo "=== SUMMARY COMPOSITION TESTS ==="
cat scripts/utils/ollamaChat.summary-composition.test.ts

echo
echo "=== REASONING COMPOSITION TESTS ==="
cat scripts/utils/ollamaChat.reasoning-composition.test.ts

echo
echo "=== EXPLANATION STATUS CONTRACT ==="
cat scripts/utils/ollamaChat.explanation-status.test.ts

echo
echo "=== EVIDENCE COMPOSITION CLOSURE ==="
sed -n '1,220p' scripts/finalize-evidence-composition-closure.sh

echo
echo "=== BOUNDARY-RELATED REPOSITORY REFERENCES ==="
rg -n -C 5 \
'boundary|scope boundary|scope boundaries|uncertainty|unresolved|constraint|out of scope|not authorized|deferred|cannot|can.t|must not|do not' \
scripts/utils \
server \
docs \
--glob='*.ts' \
--glob='*.md' \
--glob='*.sh' \
| head -n 320 || true

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
Evidence Composition is closed.

The next Response Composition corridor is Boundary Composition.

Investigate current repository capability before proposing implementation.

Boundary Composition means preserving user-visible limits that materially affect
the conclusion or next action without turning every response into a disclaimer
inventory.

Determine:

1. What kinds of boundaries already exist in the current semantic context?
   Inspect at minimum:
   - scope boundaries;
   - architectural invariants;
   - authorization limits;
   - unresolved uncertainty;
   - unavailable evidence;
   - deferred work;
   - unsupported capability claims.

2. Which of those boundaries are currently represented as structured runtime
   state versus only natural-language prompt instructions?

3. Does Summary Composition already instruct Matilda to preserve material scope
   boundaries and uncertainty?

4. Does Reasoning Composition already instruct Matilda to surface material
   uncertainty or implementation boundaries when they affect the conclusion?

5. Does Evidence Composition already provide any deterministic boundary signal,
   such as insufficient/unavailable evidence, without owning general Boundary
   Composition?

6. Is there currently any dedicated structured Boundary artifact or Boundary
   Status in the Ollama response contract?

7. Can Boundary Composition be implemented inside the existing single semantic
   invocation without adding a second model call?

8. Would a new structured boundary artifact improve deterministic composition,
   or would it duplicate information already represented by:
   - explanationStatus;
   - evidenceSufficient;
   - priorExplanationEvidenceStatus;
   - projectContextWarning;
   - durableInterpretation?

9. What exact behavioral gap remains between the current prompt contract and the
   V3 Boundary Composition objective?

10. Is that gap:
    a. already implemented and merely undocumented;
    b. prompt-level but not behaviorally validated;
    c. structurally missing;
    d. not yet determinable from repository evidence?

11. What is the smallest safe next unit:
    - behavioral validation only;
    - bounded prompt contract;
    - deterministic boundary signal;
    - structured boundary artifact;
    - or further investigation?

Return exactly one classification:

BOUNDARY_COMPOSITION_ALREADY_PRESENT
BOUNDARY_COMPOSITION_BEHAVIORAL_VALIDATION_READY
BOUNDARY_COMPOSITION_PROMPT_CONTRACT_READY
BOUNDARY_COMPOSITION_DETERMINISTIC_SIGNAL_READY
BOUNDARY_COMPOSITION_STRUCTURED_ARTIFACT_READY
BOUNDARY_COMPOSITION_NOT_READY

Then identify exactly one smallest next unit.

Do not implement.
Do not modify runtime.
Do not begin Adaptive Detail Selection.
Do not redesign Summary Composition, Reasoning Composition, or Evidence
Composition.
Preserve one user message -> one workflow -> one Ollama invocation.
Use repository evidence only.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
