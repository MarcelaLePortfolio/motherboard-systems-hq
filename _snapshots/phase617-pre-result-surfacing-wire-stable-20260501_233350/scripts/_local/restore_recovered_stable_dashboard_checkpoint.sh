#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

ARCHIVE_PATH=".artifacts/docker/motherboard_systems_hq-dashboard_v60.1-recovered-stable-dashboard-checkpoint-20260309.tar"
IMAGE_FROZEN="motherboard_systems_hq-dashboard:v60.1-recovered-stable-dashboard-checkpoint-20260309"
IMAGE_TARGET="motherboard_systems_hq-dashboard:latest"

test -f "$ARCHIVE_PATH"
docker load -i "$ARCHIVE_PATH"
docker image inspect "$IMAGE_FROZEN" >/dev/null
docker image tag "$IMAGE_FROZEN" "$IMAGE_TARGET"
docker compose rm -sf dashboard || true
docker compose up -d --no-build dashboard
docker compose ps dashboard
