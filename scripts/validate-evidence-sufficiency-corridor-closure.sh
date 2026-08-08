#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== EVIDENCE SUFFICIENCY — CLOSURE VALIDATION ==="

echo
echo "=== REQUIRED CAPABILITIES ==="
rg -n -C 4 \
'isExplicitExplanationRequest|recoverMatildaPriorSupportProvenance|supportSourceReferences|evidenceSufficient|priorExplanationEvidenceStatus' \
server/matilda-chat-workflow.ts \
server/matilda-explanation-request-signal.ts \
server/matilda-prior-support-provenance.ts \
server/matilda-support-provenance.ts \
scripts/utils/ollamaChat.ts

echo
echo "=== VALIDATION SUITE ==="
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
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "=== CLOSURE DETERMINATION ==="
cat <<'QUESTION'
Validate whether the Evidence Sufficiency corridor is now complete.

Required closure conditions:

1. Stable conversation and project-context source identifiers are supplied.
2. The semantic invocation emits bounded supportSourceReferences.
3. Returned references are structurally validated.
4. Returned references are validated against sources supplied to that invocation.
5. Duplicate references are handled deterministically.
6. evidenceSufficient is derived deterministically.
7. Original-turn support provenance is persisted in the IEL.
8. A bounded deterministic Explanation Request Signal exists before Ollama.
9. Prior-turn support provenance is recovered through existing interpretationEntryId lineage.
10. Explicit explanation requests receive prior evidence status before the single Ollama invocation.
11. Insufficient or unavailable prior evidence prevents invented engineering justification.
12. Sufficient prior evidence permits grounded explanation.
13. One user message -> one workflow -> one Ollama invocation remains preserved.
14. Matilda remains the sole semantic author.
15. No hidden reasoning or chain-of-thought is persisted.
16. Dedicated validation covers the new deterministic behavior.

Return exactly one classification:

EVIDENCE_SUFFICIENCY_CLOSED
EVIDENCE_SUFFICIENCY_REMAINS_OPEN

If OPEN, identify only the specific unmet closure condition.
Do not begin Reasoning Composition.
Do not begin Evidence Composition.
Do not modify runtime code.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
