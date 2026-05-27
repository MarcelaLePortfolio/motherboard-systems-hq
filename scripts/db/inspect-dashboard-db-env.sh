#!/bin/sh
set -eu

echo "🔎 Inspecting dashboard container DB env + connectivity..."
echo

docker-compose exec dashboard sh -c '
  echo "Environment vars relevant to Postgres:"
  env | grep -E "DATABASE_URL|PGHOST|PGUSER|PGPASSWORD|PGDATABASE|POSTGRES" || echo "(none)"

  echo
  echo "Trying a simple psql connection if available..."
  if command -v psql >/dev/null 2>&1; then
    if [ -n "${PGUSER:-}" ] && [ -n "${PGDATABASE:-}" ]; then
      echo
      echo "psql -c \"SELECT current_user, current_database();\""
      psql -c "SELECT current_user, current_database();"
    else
      echo
      echo "PGUSER/PGDATABASE not set; trying manual connection to postgres://user:password@postgres:5432/motherboarddb"
      echo "PGPASSWORD=password psql -h postgres -U user -d motherboarddb -c \"SELECT current_user, current_database();\""
      PGPASSWORD=password psql -h postgres -U user -d motherboarddb -c "SELECT current_user, current_database();" || echo "(manual psql test failed)"
    fi
  else
    echo
    echo "psql not installed in dashboard container."
  fi
'

echo
echo "✅ Dashboard DB env inspect complete."
