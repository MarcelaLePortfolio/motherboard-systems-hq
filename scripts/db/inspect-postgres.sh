#!/bin/bash
set -euo pipefail

echo "🔎 Inspecting Postgres env + roles inside docker-compose 'postgres' service..."
echo

docker-compose exec postgres bash -lc '
  echo "POSTGRES_* env variables:"
  env | grep -E "^POSTGRES_" || echo "(no POSTGRES_* variables visible)"

  echo
  echo "psql: list roles (\\du) using \$POSTGRES_USER / \$POSTGRES_DB if available..."
  if command -v psql >/dev/null 2>&1; then
    if [ -n "${POSTGRES_USER:-}" ] && [ -n "${POSTGRES_DB:-}" ]; then
      echo
      echo "Connecting with: psql -U \"$POSTGRES_USER\" -d \"$POSTGRES_DB\""
      echo
      psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\du" || echo "(psql \\du failed)"

      echo
      echo "psql: list databases (\\l)..."
      echo
      psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\l" || echo "(psql \\l failed)"
    else
      echo
      echo "POSTGRES_USER or POSTGRES_DB not set; skipping psql introspection."
    fi
  else
    echo
    echo "psql not found inside container."
  fi
'

echo
echo "✅ Postgres inspect complete."
