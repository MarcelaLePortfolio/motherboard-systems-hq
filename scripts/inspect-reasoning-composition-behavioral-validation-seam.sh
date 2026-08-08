#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== REASONING COMPOSITION — BEHAVIORAL VALIDATION SEAM ==="

echo
echo "=== EXISTING SEMANTIC / LIVE OLLAMA VALIDATION ==="
rg -n -C 8 \
'semantic runtime|semantic.*validation|OLLAMA_BASE_URL|localhost:11434|gemma3:4b|ollamaChat\(|verify-matilda|behavioral validation|live.*ollama|real.*ollama' \
scripts \
server \
docs \
package.json \
--glob '!dist/**' \
--glob '!node_modules/**' \
| head -420 || true

echo
echo "=== REASONING COMPOSITION CONTRACT ==="
rg -n -C 12 \
'For a permitted explanation|governing rationale|material tradeoffs|material uncertainty|evidence inventory' \
scripts/utils/ollamaChat.ts \
scripts/utils/ollamaChat.reasoning-composition.test.ts

echo
echo "=== EXISTING EXPLANATION VALIDATION ==="
sed -n '1,220p' scripts/utils/ollamaChat.explanation-request.test.ts
sed -n '1,240p' scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts

echo
echo "=== PACKAGE TEST / VERIFY COMMANDS ==="
node -e '
const p=require("./package.json");
console.log(JSON.stringify({
  scripts:Object.fromEntries(
    Object.entries(p.scripts||{}).filter(([k]) =>
      /matilda|semantic|verify|ollama|test/.test(k)
    )
  )
}, null, 2));
'

echo
echo "=== QUESTION ==="
cat <<'QUESTION'
Reasoning Composition now has an explicit prompt-owned composition contract:

1. conclusion/recommendation
2. governing rationale
3. material tradeoffs when relevant
4. material uncertainty or unresolved limits when relevant

The current dedicated unit test verifies that this contract reaches the single
Ollama invocation. It does not independently demonstrate that the live semantic
runtime follows the composition behavior.

Determine the smallest existing behavioral-validation seam.

Specifically determine:

1. Is there already a repository-controlled test or verification script that
   invokes the real configured Ollama model rather than mocking fetch?

2. Has that seam already been used to validate semantic authorship or other
   model-authored behavior?

3. Can Reasoning Composition be behaviorally validated through that same seam
   without adding another runtime or model invocation to production?

4. What observable behaviors are safe to validate without evaluating hidden
   chain-of-thought?

Candidate observable behaviors:

A. Explanation begins by making the prior conclusion/recommendation clear.

B. Explanation states a user-visible governing rationale.

C. Material tradeoffs are included only when relevant to the supplied case.

D. Material uncertainty is included when materially present in supplied context.

E. Explanation does not expose hidden reasoning or chain-of-thought.

F. Explanation does not mechanically emit headings or every composition element
   when irrelevant.

5. Should behavioral validation inspect only the user-visible reply, while
   treating supportSourceReferences and Evidence Sufficiency as already-closed
   deterministic prerequisites?

6. Is any additional Reasoning Composition runtime capability required before
   behavioral validation can begin?

Return exactly one classification:

BEHAVIORAL_VALIDATION_READY
NEEDS_REASONING_RUNTIME_CAPABILITY
NO_EXISTING_VALIDATION_SEAM

If BEHAVIORAL_VALIDATION_READY, identify the smallest validation implementation
unit.

Do not modify the Reasoning Composition contract.
Do not begin Evidence Composition.
Do not begin Boundary Composition.
Do not begin Adaptive Detail Selection.
Do not add another production model invocation.
Use repository evidence only.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
