
set -euo pipefail

PG_CID="$(docker compose ps -q postgres | head -n 1)"
if [[ -z "${PG_CID:-}" ]]; then
  echo "echo 'postgres container not found (docker compose ps -q postgres)'; return 2"
  exit 2
fi

PG_USER="$(docker exec "$PG_CID" printenv POSTGRES_USER)"
PG_PASS="$(docker exec "$PG_CID" printenv POSTGRES_PASSWORD)"
PG_DB="$(docker exec "$PG_CID" printenv POSTGRES_DB)"

DATABASE_URL="postgres://${PG_USER}:${PG_PASS}@127.0.0.1:5432/${PG_DB}"
printf "export DATABASE_URL=%q\n" "$DATABASE_URL"
printf "export POSTGRES_URL=%q\n" "$DATABASE_URL"
