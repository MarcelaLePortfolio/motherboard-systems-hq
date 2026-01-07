
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SQL_FILE="${1:-}"
if [[ -z "${SQL_FILE}" || ! -f "${SQL_FILE}" ]]; then
  echo "usage: $0 <sql-file-path-on-host>"
  exit 2
fi

PG_CID="$(docker compose ps -q postgres | head -n 1)"
if [[ -z "${PG_CID:-}" ]]; then
  echo "postgres container not found (docker compose ps -q postgres)."
  exit 2
fi

PG_USER="$(docker exec "$PG_CID" printenv POSTGRES_USER)"
PG_PASS="$(docker exec "$PG_CID" printenv POSTGRES_PASSWORD)"
PG_DB="$(docker exec "$PG_CID" printenv POSTGRES_DB)"

cat "$SQL_FILE" | docker exec -e PGPASSWORD="$PG_PASS" -i "$PG_CID" \
  psql -U "$PG_USER" -d "$PG_DB" -h 127.0.0.1 -p 5432 -v ON_ERROR_STOP=1
