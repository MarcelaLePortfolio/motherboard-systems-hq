#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v149.5-execution-capability-audited-governance-prelive-summary-corridor-golden"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "[phase149.5] refusing to proceed: working tree is not clean"
  git status --short
  exit 1
fi

echo "[phase149.5] current branch: $(git rev-parse --abbrev-ref HEAD)"
echo "[phase149.5] current commit: $(git rev-parse --short HEAD)"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "[phase149.5] tag already exists locally: $TAG"
else
  git tag -a "$TAG" -m "Phase 149.5 golden checkpoint"
  echo "[phase149.5] created local tag: $TAG"
fi

echo "[phase149.5] pushing tag"
git push origin "$TAG"

if [[ -f docker-compose.yml ]]; then
  echo "[phase149.5] docker compose build"
  docker compose -f docker-compose.yml build

  echo "[phase149.5] docker compose up -d"
  docker compose -f docker-compose.yml up -d

  echo "[phase149.5] docker compose ps"
  docker compose -f docker-compose.yml ps

  echo "[phase149.5] dashboard health snapshot"
  docker compose -f docker-compose.yml ps dashboard || true

  echo "[phase149.5] postgres health snapshot"
  docker compose -f docker-compose.yml ps postgres || true
else
  echo "[phase149.5] no docker-compose.yml found"
  exit 1
fi

echo "[phase149.5] PASS"
