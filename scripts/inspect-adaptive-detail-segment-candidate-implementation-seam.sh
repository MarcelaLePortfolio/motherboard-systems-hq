#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — SEGMENT CANDIDATE IMPLEMENTATION SEAM ==="

if [[ "$(git rev-parse --short HEAD)" != "5f126a04" ]]; then
  echo "STOP: HEAD no longer matches contract baseline 5f126a04."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/inspect-adaptive-detail-segment-candidate-implementation-seam\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== RETRIEVAL CONTRACT + SEGMENTATION PRIMITIVE ==="
grep -n -B 20 -A 120 \
  -E 'MatildaProjectContextRetrieval|MatildaProjectContextExcerpt|DeterministicProjectContextSegment|segment|readBoundedExcerpt|excerpts.push' \
  server/matilda-project-context-retrieval.ts

echo
echo "=== CONVERSATION CONTEXT CONTRACT ==="
sed -n '1,150p' \
  server/matilda-conversation-context-runtime.ts

echo
echo "=== WORKFLOW PASSAGE ==="
sed -n '125,210p' \
  server/matilda-chat-workflow.ts

echo
echo "=== OLLAMA CONTEXT TYPE ==="
sed -n '120,165p' \
  scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT SEGMENTATION TESTS ==="
sed -n '1,260p' \
  server/matilda-project-context-retrieval.segmentation.test.ts

echo
echo "=== RANGE METADATA TESTS ==="
sed -n '1,240p' \
  server/matilda-project-context-retrieval.range-metadata.test.ts

echo
echo "=== CONVERSATION CONTEXT TESTS ==="
sed -n '1,190p' \
  server/matilda-conversation-context-runtime.test.ts

echo
echo "=== PROMPT SERIALIZATION CHECK ==="
grep -n \
  -E 'projectContextSegmentCandidates|selectedContextSegments' \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-project-context-retrieval.ts || true

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_IMPLEMENTATION_SEAM_INSPECTED"
echo "IMPLEMENTATION_NOT_STARTED"
