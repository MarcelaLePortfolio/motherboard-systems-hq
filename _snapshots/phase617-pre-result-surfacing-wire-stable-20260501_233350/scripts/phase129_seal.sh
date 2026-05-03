#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v129.0-governance-execution-routing-golden"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to seal: working tree is not clean."
  git status --short
  exit 1
fi

bash scripts/phase129_governance_routing_smoke.sh

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists locally: $TAG"
else
  git tag -a "$TAG" -m "Phase 129 governance execution routing golden checkpoint"
  echo "Created local tag: $TAG"
fi

git push origin "$TAG"

if command -v docker >/dev/null 2>&1; then
  if [[ -f docker-compose.yml ]]; then
    docker compose -f docker-compose.yml config >/dev/null
    echo "Docker compose config valid"
  fi
fi

echo "Phase 129 seal COMPLETE"

