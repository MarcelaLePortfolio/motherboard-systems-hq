#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

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
git log --oneline -5
