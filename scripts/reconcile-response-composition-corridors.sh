#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RESPONSE COMPOSITION — CORRIDOR RECONCILIATION ==="

echo
echo "=== ORIGINAL CORRIDOR MAP ==="
cat <<'MAP'
1. Summary Composition
2. Reasoning Classification
3. Evidence Composition
4. Boundary Composition
5. Adaptive Detail Selection
MAP

echo
echo "=== SUMMARY COMPOSITION EVIDENCE ==="
rg -n -C 3 \
'Lead with a concise natural-language summary|opening summary|Summary Composition' \
scripts/utils/ollamaChat.ts \
scripts/utils/ollamaChat.summary-composition.test.ts \
scripts/guard-ollama-response-contract.sh \
docs \
--glob '!node_modules/**' \
--glob '!dist/**' \
| head -180 || true

echo
echo "=== REASONING CLASSIFICATION EVIDENCE ==="
rg -n -C 4 \
'explanationStatus|Explanation Status|reasoning classification|Reasoning Classification|optional|recommended' \
scripts/utils/ollamaChat.ts \
scripts/utils/ollamaChat.explanation-status.test.ts \
server \
docs \
--glob '!node_modules/**' \
--glob '!dist/**' \
| head -240 || true

echo
echo "=== EVIDENCE COMPOSITION EVIDENCE ==="
rg -n -C 4 \
'supportSourceReferences|projectContextExcerpts|Bounded project context evidence|support provenance|Evidence Composition|evidence sufficiency' \
scripts/utils/ollamaChat.ts \
scripts/utils/ollamaChat.support-source-references.test.ts \
server \
docs \
--glob '!node_modules/**' \
--glob '!dist/**' \
| head -280 || true

echo
echo "=== BOUNDARY COMPOSITION EVIDENCE ==="
rg -n -C 4 \
'Preserve material uncertainty|scope boundaries|evidence distinctions|Do not strengthen|Do not claim certainty|Boundary Composition|implementation boundaries' \
scripts/utils/ollamaChat.ts \
server \
docs \
--glob '!node_modules/**' \
--glob '!dist/**' \
| head -240 || true

echo
echo "=== ADAPTIVE DETAIL SELECTION EVIDENCE ==="
rg -n -C 4 \
'After the opening summary|supporting detail needed|Adaptive Detail Selection|adaptive detail|explanationStatus|optional|recommended' \
scripts/utils/ollamaChat.ts \
scripts/utils \
server \
docs \
--glob '!node_modules/**' \
--glob '!dist/**' \
| head -240 || true

echo
echo "=== RECONCILIATION RULE ==="
cat <<'RULE'
For each original corridor classify separately:

IMPLEMENTED_AND_VALIDATED
IMPLEMENTED_BUT_NOT_FULLY_VALIDATED
ARCHITECTURE_RESOLVED_IMPLEMENTATION_INCOMPLETE
NEEDS_RESCOPE
OPEN

Do not mark a corridor complete merely because related prompt language exists.
Do not mark a corridor complete merely because its architectural uncertainty was resolved.
Do not merge deterministic provenance infrastructure with semantic composition.
RULE

echo
echo "=== QUESTIONS TO RESOLVE ==="
cat <<'QUESTIONS'
1. Is Summary Composition still IMPLEMENTED_AND_VALIDATED?

2. Does Reasoning Classification remain a valid corridor, or has its original
   scope split between:
   - deterministic Evidence Sufficiency; and
   - semantic Reasoning Composition?

3. Is Evidence Composition:
   - implemented;
   - architecture-resolved but implementation-incomplete; or
   - already satisfied by support provenance infrastructure?

4. Does Boundary Composition have dedicated behavior and validation, or only
   related prompt constraints?

5. Does Adaptive Detail Selection have dedicated behavior and validation, or
   only partial behavior through summary/detail instructions and
   explanationStatus?

6. Which of the original five corridors can legitimately be checked off TODAY?

Do not infer completion from naming overlap.
Use repository evidence only.
QUESTIONS

echo
echo "=== CURRENT BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
