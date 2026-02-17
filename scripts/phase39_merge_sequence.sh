#!/usr/bin/env bash
set -euo pipefail

setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

REPO_URL="$(git remote get-url origin | sed -E 's#git@github.com:([^/]+/[^.]+)\.git#https://github.com/\1#; s#https://github.com/([^/]+/[^.]+)\.git#https://github.com/\1#')"

echo "=== Phase 39 PRs (open + merge order) ==="
echo "1) Phase 39.1 planning:"
echo "   ${REPO_URL}/pull/new/feature/phase39-1-policy-authority-planning"
echo "2) Phase 39.2/39.3 impl:"
echo "   ${REPO_URL}/pull/new/feature/phase39-2-policy-evaluator"
echo

echo "=== Local safety checks ==="
git status
echo
git --no-pager log -1 --oneline
echo
echo "If you merged already, run:"
echo "  git checkout main && git pull --ff-only && git tag -l 'v39.*' | tail -n 20"
