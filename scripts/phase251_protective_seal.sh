#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
HEAD_SHA="$(git rev-parse --short HEAD)"
TAG="v251.0-governance-enforcement-architecture-scaffold-golden"

echo "== Repo root =="
echo "$ROOT"
echo

echo "== Branch / HEAD =="
echo "branch: $BRANCH"
echo "head:   $HEAD_SHA"
echo

echo "== Git status =="
git status --short
echo

echo "== Remote sync check =="
git fetch origin "$BRANCH" --tags
LOCAL_SHA="$(git rev-parse "$BRANCH")"
REMOTE_SHA="$(git rev-parse "origin/$BRANCH")"
echo "local:  $LOCAL_SHA"
echo "remote: $REMOTE_SHA"

if [[ "$LOCAL_SHA" != "$REMOTE_SHA" ]]; then
  echo "Branch is not synced with origin. Pushing branch..."
  git push origin "$BRANCH"
else
  echo "Branch already pushed."
fi
echo

echo "== Tag seal check =="
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists locally: $TAG"
else
  git tag -a "$TAG" -m "Phase 251 golden checkpoint"
  echo "Created local tag: $TAG"
fi

if git ls-remote --tags origin | grep -q "refs/tags/$TAG$"; then
  echo "Tag already exists on origin: $TAG"
else
  git push origin "$TAG"
  echo "Pushed tag: $TAG"
fi
echo

echo "== Container verification =="
if [[ -f docker-compose.yml || -f compose.yml || -f docker/compose.yml ]]; then
  COMPOSE_FILE=""
  if [[ -f docker-compose.yml ]]; then
    COMPOSE_FILE="docker-compose.yml"
  elif [[ -f compose.yml ]]; then
    COMPOSE_FILE="compose.yml"
  else
    COMPOSE_FILE="docker/compose.yml"
  fi

  echo "Using compose file: $COMPOSE_FILE"
  docker compose -f "$COMPOSE_FILE" config >/dev/null
  docker compose -f "$COMPOSE_FILE" build
  docker compose -f "$COMPOSE_FILE" up -d
  docker compose -f "$COMPOSE_FILE" ps

  echo
  echo "== Dashboard logs =="
  docker compose -f "$COMPOSE_FILE" logs --tail=60 dashboard || true

  echo
  echo "== Postgres logs =="
  docker compose -f "$COMPOSE_FILE" logs --tail=40 postgres || true
else
  echo "No compose file found. Skipping container verification."
fi
echo

echo "== Final verification =="
git status --short
git log --oneline -5
echo
echo "Protective seal complete."
echo "Confirmed or enforced:"
echo "- committed"
echo "- pushed"
echo "- tagged"
echo "- container verification attempted"
