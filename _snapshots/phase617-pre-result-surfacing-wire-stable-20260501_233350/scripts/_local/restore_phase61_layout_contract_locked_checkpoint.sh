#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

CHECKPOINT_NAME="phase61-layout-contract-locked-20260310"
ARCHIVE_PATH=".artifacts/docker/motherboard_systems_hq-dashboard_${CHECKPOINT_NAME}.tar"
IMAGE_FROZEN="motherboard_systems_hq-dashboard:${CHECKPOINT_NAME}"
IMAGE_TARGET="motherboard_systems_hq-dashboard:latest"

test -f "$ARCHIVE_PATH"
docker load -i "$ARCHIVE_PATH"
docker image inspect "$IMAGE_FROZEN" >/dev/null
docker image tag "$IMAGE_FROZEN" "$IMAGE_TARGET"
docker compose rm -sf dashboard || true
docker compose up -d --no-build dashboard
docker compose ps dashboard
