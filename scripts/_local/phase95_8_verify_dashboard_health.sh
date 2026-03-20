#!/usr/bin/env bash
set -euo pipefail

CID="$(docker compose ps -q dashboard)"

if [ -z "${CID:-}" ]; then
  echo "ERROR: dashboard container not found" >&2
  exit 1
fi

docker inspect "$CID" --format '{{.State.Health.Status}}'
docker inspect "$CID" --format '{{range .State.Health.Log}}{{println .ExitCode .Output}}{{end}}' || true
