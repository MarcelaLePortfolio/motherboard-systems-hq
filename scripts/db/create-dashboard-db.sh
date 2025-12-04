#!/bin/sh
set -eu

echo "🗄️ Ensuring 'dashboard_db' database exists in docker postgres container..."

docker-compose exec postgres sh -c '
  set -eu

  : "${POSTGRES_USER:?POSTGRES_USER is required}"
  : "${POSTGRES_DB:?POSTGRES_DB is required}"

  echo "➡️ Using POSTGRES_USER=${POSTGRES_USER}, POSTGRES_DB=${POSTGRES_DB} as control database"

  EXISTS=$(psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT 1 FROM pg_database WHERE datname = '\''dashboard_db'\''")

  if [ -z "$EXISTS" ]; then
    echo "🆕 Creating database dashboard_db owned by ${POSTGRES_USER}..."
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "CREATE DATABASE dashboard_db OWNER ${POSTGRES_USER};"
  else
    echo "✅ Database dashboard_db already exists."
  fi
'

echo "✅ Dashboard DB check complete."
