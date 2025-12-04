
set -euo pipefail

echo "🔐 Ensuring 'postgres' role exists in docker postgres container..."

docker-compose exec postgres bash -lc '
  set -e

  : "${POSTGRES_USER:?POSTGRES_USER is required}"
  : "${POSTGRES_DB:?POSTGRES_DB is required}"

  echo "➡️ Connecting as \$POSTGRES_USER=\$POSTGRES_USER to \$POSTGRES_DB=\$POSTGRES_DB"

  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 <<SQL
CREATE ROLE IF NOT EXISTS postgres WITH LOGIN PASSWORD '\''postgres'\'';
SQL
'

echo "✅ Role check complete."
