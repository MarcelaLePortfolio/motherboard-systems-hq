#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v382.0-replay-verification-proof-suite-golden"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to seal: working tree is not clean."
  git status --short
  exit 1
fi

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists locally: $TAG"
else
  git tag -a "$TAG" -m "Phase 382 replay verification proof suite golden checkpoint"
  echo "Created local tag: $TAG"
fi

git push origin "$TAG"

if command -v docker >/dev/null 2>&1; then
  if [[ -f docker-compose.yml ]]; then
    docker compose -f docker-compose.yml config >/dev/null
    docker compose ps
  fi
fi

echo "Phase 382 golden checkpoint sealed."
