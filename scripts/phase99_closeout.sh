#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "RUNNING PHASE 99 CLOSEOUT CHECKS..."

pnpm exec tsx src/cognition/confidence/confidenceInvariant.proof.ts
pnpm exec tsx scripts/_local/phase99_2_operational_confidence_smoke.ts
pnpm exec tsx scripts/_local/phase99_3_situation_summary_confidence_smoke.ts
pnpm exec tsx scripts/_local/phase99_4_guidance_confidence_smoke.ts
bash scripts/_local/phase99_cognition_invariants.sh

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

echo
echo "PHASE 99 TAGS:"
git tag --list 'v99*' --sort=version:refname

echo
echo "CONTAINER STATE:"
if command -v docker >/dev/null 2>&1; then
  docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
else
  echo "docker not installed"
fi

echo
echo "PHASE 99 CLOSEOUT: PASS"
