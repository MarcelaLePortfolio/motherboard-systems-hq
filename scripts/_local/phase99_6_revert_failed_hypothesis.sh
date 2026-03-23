#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Revert failed Phase 99.6 exploration commits only.
git revert --no-edit 4cf56595 6f9c7947 a7a69c27 ec16934b

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
git log --oneline -8
