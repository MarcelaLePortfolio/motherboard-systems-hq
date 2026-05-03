#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

docker compose build dashboard
docker compose up -d dashboard
docker compose ps dashboard
