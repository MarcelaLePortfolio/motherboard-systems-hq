#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

while git rev-parse --verify REVERT_HEAD >/dev/null 2>&1; do
  if [[ -n "$(git status --porcelain)" ]]; then
    git add -A
    git revert --continue
  else
    git revert --skip
  fi
done

git push

echo
echo "BRANCH:"
git branch --show-current

echo
echo "WORKTREE:"
git status --short

echo
echo "HEAD:"
git rev-parse --short HEAD

echo
echo "LATEST COMMITS:"
git log --oneline -10
