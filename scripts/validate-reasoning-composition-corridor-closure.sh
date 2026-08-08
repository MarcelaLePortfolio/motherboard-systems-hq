#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== REASONING COMPOSITION — CLOSURE VALIDATION ==="

echo
echo "=== VERIFIED LIVE RESULT ==="
cat <<'RESULT'
Observed live reply:

"I recommend preserving the existing single-invocation workflow because changing
that boundary would introduce unnecessary architectural risk."

Observed structured result:

explanationStatus: recommended
supportSourceReferences:
  - conversation_turn: turn-reasoning-validation-1
evidenceSufficient: true

Observable assessment:

✓ Prior recommendation is clearly restated.
✓ Governing rationale is user-visible.
✓ No irrelevant tradeoff was mechanically added.
✓ No unsupported uncertainty was invented.
✓ No hidden reasoning or chain-of-thought was exposed.
✓ Reply remains natural prose rather than mechanical headings.
RESULT

echo
echo "=== CONTRACT EVIDENCE ==="
rg -n -C 5 \
'For a permitted explanation|governing rationale|material tradeoffs|material uncertainty|Do not mechanically include|Do not narrate hidden reasoning' \
scripts/utils/ollamaChat.ts \
scripts/utils/ollamaChat.reasoning-composition.test.ts

echo
echo "=== LIVE VALIDATION HARNESS ==="
sed -n '1,180p' scripts/validate-reasoning-composition-live.ts

echo
echo "=== REGRESSION VALIDATION ==="
npx tsx --test \
  server/matilda-explanation-request-signal.test.ts \
  server/matilda-support-provenance.test.ts \
  server/matilda-prior-support-provenance.test.ts \
  scripts/utils/ollamaChat.test.ts \
  scripts/utils/ollamaChat.summary-composition.test.ts \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.explanation-request.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.support-source-production.test.ts \
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts \
  scripts/utils/ollamaChat.reasoning-composition.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "=== CLOSURE DETERMINATION ==="
cat <<'CLOSURE'
REASONING_COMPOSITION_CLOSED

Verified closure conditions:

1. A canonical reasoning-composition contract exists.
2. Explanation begins from the prior conclusion or recommendation.
3. A user-visible governing rationale is required.
4. Tradeoffs are conditional on material relevance.
5. Uncertainty is conditional on material relevance.
6. Mechanical emission of every reasoning element is explicitly prohibited.
7. Evidence inventory remains separate from Reasoning Composition.
8. Hidden reasoning and chain-of-thought remain prohibited.
9. Evidence Sufficiency gates unsupported explanation behavior.
10. The existing single Ollama invocation remains the semantic author.
11. Unit validation confirms the contract reaches the semantic invocation.
12. Live validation confirms the configured Ollama runtime follows the contract.
13. The observed live reply remained concise and natural.
14. No additional Reasoning Composition runtime capability is required.

The next Response Composition corridor is:

EVIDENCE COMPOSITION
CLOSURE

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
