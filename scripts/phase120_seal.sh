#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v120-dashboard-consumption-adapter-golden"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to seal: working tree is not clean."
  git status --short
  exit 1
fi

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists locally: $TAG"
else
  git tag -a "$TAG" -m "Phase 120 golden checkpoint"
  echo "Created local tag: $TAG"
fi

git push origin "$TAG"

echo "Phase 120 sealed."
