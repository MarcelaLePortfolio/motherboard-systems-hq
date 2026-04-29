#!/usr/bin/env bash
set -euo pipefail

echo "=== DOCKER ENTRYPOINT (LOCKED) ==="

: "${DATABASE_URL:?DATABASE_URL not set}"

echo "[entrypoint] running schema guard"
bash /scripts/schema_guard.sh

echo "[entrypoint] starting main process"
exec "$@"
