#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

CHECKPOINT_NAME="phase61-exact-current-state-20260310"
SOURCE_TAG="v61.1-${CHECKPOINT_NAME}"
IMAGE_FROZEN="motherboard_systems_hq-dashboard:${CHECKPOINT_NAME}"
ARCHIVE_PATH=".artifacts/docker/motherboard_systems_hq-dashboard_${CHECKPOINT_NAME}.tar"

git rev-parse --verify "$SOURCE_TAG"
docker image inspect "$IMAGE_FROZEN" >/dev/null
test -f "$ARCHIVE_PATH"

git --no-pager show --no-patch --oneline "$SOURCE_TAG"
docker image inspect "$IMAGE_FROZEN" --format '{{join .RepoTags "\n"}}'
ls -lh "$ARCHIVE_PATH"
docker compose ps dashboard
