#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== VALIDATE ADAPTIVE DETAIL — DETERMINISTIC SEGMENTATION BEHAVIOR ==="

if [[ "$(git rev-parse --short HEAD)" != "02514e8e" ]]; then
  echo "STOP: HEAD no longer matches segmentation primitive checkpoint 02514e8e."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/validate-adaptive-detail-deterministic-segmentation-behavior\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== SEGMENTATION PRIMITIVE ==="
grep -n -A85 -B10 \
  'function segmentBoundedProjectContextSource' \
  server/matilda-project-context-retrieval.ts

echo
echo "=== EXISTING SEGMENTATION TESTS ==="
cat server/matilda-project-context-retrieval.segmentation.test.ts

echo
echo "=== VALIDATION QUESTIONS ==="
cat <<'QUESTIONS'
Validate only the deterministic segmentation primitive.

Required behavioral cases:

1. One contiguous nonblank block -> one segment.

2. Two blocks separated by one blank line -> two segments.

3. Multiple consecutive blank lines -> no empty segments.

4. Leading blank lines -> no leading empty segment.

5. Trailing blank lines -> no trailing empty segment.

6. Segment content preserves original nonblank source lines and order.

7. startLineNumber and endLineNumber exactly correspond to source positions.

8. matchedLineNumber is preserved identically on every segment derived from the
   same bounded source.

9. Multiple segments from one bounded source have distinct:
   relativePath + startLineNumber + endLineNumber identities.

10. Whitespace-only lines behave as blank separators because the primitive uses
    trim() only for separator detection.

11. Nonblank line content itself is not trimmed, normalized, ranked, scored, or
    semantically filtered.

12. The primitive remains inert:
    its returned segments are not used to construct MatildaProjectContextExcerpt,
    MatildaConversationContext, Ollama input, supportSourceReferences, evidence,
    or evidenceSufficient.

13. Existing project-context retrieval behavior remains unchanged.

14. Existing response-contract and single-invocation guarantees remain unchanged.

Do not implement semantic admission.

Do not expose segments to Ollama.

Do not change retrieval ranking, query extraction, MAX_MATCHES, or candidate
selection.

Do not change supportSourceReferences, evidenceSufficient, or Evidence
Composition.

Do not reopen Boundary Composition.
QUESTIONS

echo
echo "=== STRUCTURAL SEGMENTATION TEST ==="
npx tsx --test \
  server/matilda-project-context-retrieval.segmentation.test.ts

echo
echo "=== RANGE + RETRIEVAL REGRESSION TESTS ==="
npx tsx --test \
  server/matilda-project-context-retrieval.range-metadata.test.ts \
  server/matilda-project-context-retrieval.test.ts \
  server/matilda-conversation-context-runtime.test.ts

echo
echo "=== EVIDENCE REGRESSION TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.support-source-production.test.ts \
  scripts/utils/ollamaChat.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_DETERMINISTIC_SEGMENTATION_BEHAVIOR_VALIDATION_COMPLETE"
echo "SEMANTIC_ADMISSION_NOT_STARTED"
