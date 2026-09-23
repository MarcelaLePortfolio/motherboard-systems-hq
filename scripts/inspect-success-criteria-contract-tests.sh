#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

echo "===== PACKAGE SEMANTICS CONTRACT TEST ====="
cat scripts/utils/ollamaChat.package-semantics-contract.test.ts

echo
echo "===== PACKAGE SEMANTICS FIDELITY TEST ====="
cat scripts/utils/ollamaChat.package-semantics-fidelity.test.ts

echo
echo "===== PACKAGE SEMANTICS OBSERVER TEST ====="
cat scripts/utils/ollamaChat.package-semantics-observer.test.ts 2>/dev/null || true

echo
echo "===== EXACT OUTPUT SCHEMA REGION ====="
sed -n '170,220p' scripts/utils/ollamaChat.ts

echo
echo "===== EXACT VALIDATOR REGIONS ====="
sed -n '360,490p' scripts/utils/ollamaChat.ts

echo
echo "===== PACKAGE SEMANTICS PROMPT LINES ====="
grep -n -E \
  'Package Semantics|packageSemantics|expectedOutcome|proposedWork|unresolvedQuestions' \
  scripts/utils/ollamaChat.ts | tail -120

echo
echo "===== TYPECHECK CONFIRMATION ====="
npx tsc --noEmit || true

echo
echo "===== BASELINE / PRESERVED WORKTREE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'
git status --short --untracked-files=no
