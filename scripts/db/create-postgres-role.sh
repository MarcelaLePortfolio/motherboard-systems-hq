#!/bin/sh
set -eu

echo "🔐 Ensuring 'postgres' role exists in docker postgres container..."

docker-compose exec postgres sh -c '
  set -eu

  : "${POSTGRES_USER:?POSTGRES_USER is required}"
  : "${POSTGRES_DB:?POSTGRES_DB is required}"

  echo "➡️ Connecting as ${POSTGRES_USER} to DB ${POSTGRES_DB} to ensure role '\''postgres'\'' exists"

  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<SQL
DO
$$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = ''postgres'') THEN
    CREATE ROLE postgres WITH LOGIN PASSWORD ''password'';
  END IF;
END
$$;
SQL
'

echo "✅ Role check complete."
