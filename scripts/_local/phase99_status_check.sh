#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

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

echo
echo "PHASE TAGS:"
git tag --list 'v99.*' --sort=version:refname | tail -n 6

echo
echo "TAG REMOTES:"
git ls-remote --tags origin 'v99.2-operational-confidence-synthesis-golden' 'v99.3-situation-summary-confidence-integration-golden'

echo
echo "CONTAINER STATE:"
if command -v docker >/dev/null 2>&1; then
  docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
else
  echo "docker not installed"
fi
