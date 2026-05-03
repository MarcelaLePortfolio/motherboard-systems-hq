#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v190.5-governance-execution-gate"
SERVICE="dashboard"

echo "==> verifying git status"
git status --short

echo "==> ensuring tag exists locally"
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "tag present: $TAG"
else
  git tag "$TAG"
  echo "created tag: $TAG"
fi

echo "==> ensuring tag exists on origin"
if git ls-remote --tags origin | grep -q "refs/tags/$TAG$"; then
  echo "tag already pushed: $TAG"
else
  git push origin "$TAG"
fi

echo "==> rebuilding dashboard container"
docker compose build "$SERVICE"
docker compose up -d "$SERVICE"

echo "==> resolving container id"
CONTAINER="$(docker compose ps -q "$SERVICE")"
if [[ -z "$CONTAINER" ]]; then
  echo "failed to resolve container id for service: $SERVICE" >&2
  exit 1
fi

echo "==> waiting for health/status"
for _ in $(seq 1 30); do
  STATUS="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$CONTAINER")"
  echo "health/status: $STATUS"
  if [[ "$STATUS" == "healthy" || "$STATUS" == "running" ]]; then
    break
  fi
  sleep 2
done

FINAL_STATUS="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$CONTAINER")"
echo "final health/status: $FINAL_STATUS"

echo "==> compose status"
docker compose ps

echo "==> dashboard logs"
docker logs "$CONTAINER" --tail 50

echo "==> phase 190.5 seal verification complete"
