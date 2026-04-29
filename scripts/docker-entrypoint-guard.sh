#!/bin/sh
set -e

echo "=== DOCKER ENTRYPOINT GUARD (SHARED CONTRACT) ==="

: "${DATABASE_URL:?DATABASE_URL not set}"

echo "[guard] waiting for postgres readiness"
until pg_isready -d "$DATABASE_URL" >/dev/null 2>&1; do
  sleep 2
done

echo "[guard] running schema guard"
sh /scripts/schema_guard.sh

echo "[guard] starting service"
exec "$@"
