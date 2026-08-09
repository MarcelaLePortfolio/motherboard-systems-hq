#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — RANGE METADATA EDIT SURFACE ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

if [[ "$(git rev-parse --short HEAD)" != "d4028313" ]]; then
  echo "STOP: HEAD no longer matches inspected checkpoint d4028313."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/inspect-adaptive-detail-range-metadata-edit-surface\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== EXCERPT AND RETRIEVAL CONTRACTS ==="
sed -n '40,75p' server/matilda-project-context-retrieval.ts

echo
echo "=== BOUNDED EXCERPT OWNER ==="
sed -n '155,190p' server/matilda-project-context-retrieval.ts

echo
echo "=== EXCERPT CONSTRUCTION PATH ==="
sed -n '315,365p' server/matilda-project-context-retrieval.ts

echo
echo "=== CURRENT RETRIEVAL TESTS ==="
sed -n '1,320p' server/matilda-project-context-retrieval.test.ts

echo
echo "=== DOWNSTREAM EXCERPT CONSUMPTION ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E '\.excerpts|projectContextExcerpts|MatildaProjectContextExcerpt' \
  server scripts db \
  | grep -vE \
    'document-|inspect-|investigate-' \
  | head -n 220

echo
echo "=== CONTRACT FINDINGS RELEVANT TO EDIT ==="
grep -n -E \
  'excerptStartLine|excerptEndLine|excerptTruncated|metadata|MatildaProjectContextExcerpt|MatildaProjectContextRetrievalResult|readBoundedExcerpt' \
  scripts/document-adaptive-detail-excerpt-range-metadata-contract-findings.sh \
  | head -n 180

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_RANGE_METADATA_EDIT_SURFACE_INSPECTED"
echo "IMPLEMENTATION_NOT_STARTED"
