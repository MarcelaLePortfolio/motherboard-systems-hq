#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

STASH_NAME="phase487-reconcile-$(date +%Y%m%d-%H%M%S)"

git status --short

git stash push -u -m "$STASH_NAME"

git fetch origin phase119-dashboard-cognition-contract
git rebase origin/phase119-dashboard-cognition-contract
git push origin HEAD:phase119-dashboard-cognition-contract

if git stash list | grep -Fq "$STASH_NAME"; then
  git stash pop
fi

git status --short
