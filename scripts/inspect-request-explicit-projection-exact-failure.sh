#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"

test "$(git branch --show-current)" = "$BRANCH"
git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== EXACT WORKFLOW SOURCE ==="
nl -ba server/matilda-chat-workflow.ts | sed -n '365,435p'

echo
echo "=== RECONCILIATION REFERENCES ==="
grep -n -C 6 -E \
  'projectRequestExplicitPackageSemantics|reconciledPackageSemantics|ollamaResult.packageSemantics' \
  server/matilda-chat-workflow.ts || true

echo
echo "=== IMPLEMENTATION FILES ==="
sed -n '1,180p' server/matilda-request-explicit-package-semantics.ts
sed -n '1,180p' server/matilda-request-explicit-package-semantics.test.ts

echo
echo "=== TARGETED WORKTREE DIFF ==="
git diff -- server/matilda-chat-workflow.ts
git status --short -- \
  server/matilda-chat-workflow.ts \
  server/matilda-request-explicit-package-semantics.ts \
  server/matilda-request-explicit-package-semantics.test.ts

echo
echo "=== CURRENT CHECKPOINT ==="
git rev-parse --short=9 HEAD
echo "SOURCE_MUTATION_PERFORMED=NO"
echo "IMPLEMENTATION_REPAIR_PERFORMED=NO"
echo "DOGFOOD_PERFORMED=NO"
echo "NEXT_ACTION=CLASSIFY_EXACT_SOURCE_BEFORE_REPAIR"
