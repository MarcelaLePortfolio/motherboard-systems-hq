#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

ARCHIVE=".artifacts/docker/motherboard_systems_hq-dashboard_v60.1-dashboard-hierarchy-polish-preview.tar"
IMAGE="motherboard_systems_hq-dashboard:v60.1-dashboard-hierarchy-polish-preview"
TARGET_TAG="motherboard_systems_hq-dashboard:latest"

test -f "$ARCHIVE"

docker load -i "$ARCHIVE"
docker image inspect "$IMAGE" >/dev/null
docker image tag "$IMAGE" "$TARGET_TAG"

docker compose rm -sf dashboard || true
docker compose up -d --no-build dashboard

docker image inspect "$TARGET_TAG" --format '{{join .RepoTags "\n"}}'
docker compose ps dashboard
