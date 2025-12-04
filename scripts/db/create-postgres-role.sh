#!/bin/bash
set -euo pipefail

echo "🔐 Ensuring 'postgres' role exists in docker postgres container..."

docker-compose exec postgres bash -lc '
  set -e

  : "${POSTGRES_USER:?POSTGRES_USER is required}"
  : "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required}"
  : "${POSTGRES_DB:?POSTGRES_DB is required}"

  export PGPASSWORD="$POSTGRES_PASSWORD"

  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<SQL
DO
$$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = ''postgres'') THEN
    CREATE ROLE postgres WITH LOGIN PASSWORD ''$POSTGRES_PASSWORD'';
  END IF;
END
$$;
SQL
'
echo "✅ Role check complete."
