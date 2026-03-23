#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v99.3-situation-summary-confidence-contract-golden"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to seal: working tree is not clean."
  git status --short
  exit 1
fi

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists locally: $TAG"
else
  git tag -a "$TAG" -m "Phase 99.3 golden checkpoint"
  echo "Created local tag: $TAG"
fi

git push origin "$TAG"

if command -v docker >/dev/null 2>&1; then
  if [[ -f docker-compose.yml ]]; then
    docker compose -f docker-compose.yml config >/dev/null
    docker compose -f docker-compose.yml build
  elif [[ -f compose.yml ]]; then
    docker compose -f compose.yml config >/dev/null
    docker compose -f compose.yml build
  elif [[ -f compose.yaml ]]; then
    docker compose -f compose.yaml config >/dev/null
    docker compose -f compose.yaml build
  else
    echo "No canonical compose file found at repo root; skipping container build."
  fi
else
  echo "Docker not available; skipping container build."
fi

echo "Phase 99.3 sealing complete."
