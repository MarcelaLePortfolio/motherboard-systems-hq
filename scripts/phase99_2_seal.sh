#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v99.2-operational-confidence-synthesis-golden"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to seal: working tree is not clean."
  git status --short
  exit 1
fi

pnpm exec tsx src/cognition/confidence/confidenceInvariant.proof.ts
pnpm exec tsx scripts/_local/phase99_2_operational_confidence_smoke.ts

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists locally: $TAG"
else
  git tag -a "$TAG" -m "Phase 99.2 golden checkpoint"
  echo "Created local tag: $TAG"
fi

git push origin "$TAG"

echo "Phase 99.2 sealed at $TAG"
