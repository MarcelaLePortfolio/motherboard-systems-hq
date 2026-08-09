#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — RANGE METADATA IMPLEMENTATION SEAM ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

if [[ "$(git rev-parse --short HEAD)" != "c13275eb" ]]; then
  echo "STOP: HEAD no longer matches authorized checkpoint c13275eb."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/inspect-adaptive-detail-excerpt-range-implementation-seam\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "BASELINE_ACCEPTED"
echo "Only the current inspection script is untracked."

echo
echo "=== LOCATE PROJECT-CONTEXT RETRIEVAL ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'readBoundedExcerpt|MAX_EXCERPT_CHARACTERS|MatildaProjectContextRetrievalResult|MatildaProjectContextExcerpt' \
  server scripts db \
  | head -n 160

echo
echo "=== FUNCTION CONTEXT ==="
target="$(
  grep -R -l \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    -E 'function readBoundedExcerpt|const readBoundedExcerpt' \
    server scripts db \
    | grep -v 'inspect-adaptive-detail-excerpt-range-implementation-seam.sh' \
    | head -n 1
)"

if [[ -z "$target" ]]; then
  echo "STOP: readBoundedExcerpt implementation not found."
  exit 2
fi

echo "TARGET=$target"

line="$(
  grep -n -E \
    'function readBoundedExcerpt|const readBoundedExcerpt' \
    "$target" \
    | head -n 1 \
    | cut -d: -f1
)"

start=$(( line > 35 ? line - 35 : 1 ))
end=$(( line + 110 ))

sed -n "${start},${end}p" "$target"

echo
echo "=== RELATED TESTS ==="
find server scripts db \
  -type f \
  \( -name '*project-context*test.ts' -o -name '*project-context*test.tsx' \) \
  -print \
  | sort

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_EXCERPT_RANGE_IMPLEMENTATION_SEAM_INSPECTED"
echo "IMPLEMENTATION_NOT_STARTED"
