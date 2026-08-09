#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

git restore \
  --source=bf7dcaaa \
  --staged \
  --worktree \
  scripts/validate-boundary-composition-behavior.ts 2>/dev/null || true

if git ls-files --error-unmatch scripts/validate-boundary-composition-behavior.ts >/dev/null 2>&1; then
  git rm -f scripts/validate-boundary-composition-behavior.ts
fi

git status --short
git diff --check

git add -A
git commit -m "Revert Boundary behavioral regex validation hypothesis"
git push
