
set -euo pipefail

ROOT="$(cd "$(dirname "${0:A}")/.." && pwd)"
cd "$ROOT"

SQL_FILE="${1:-}"
if [[ -z "${SQL_FILE}" || ! -f "${SQL_FILE}" ]]; then
  echo "usage: $0 <sql-file-path-on-host> [logfile]"
  echo "error: missing or unreadable SQL_FILE: ${SQL_FILE:-<empty>}"
  exit 2
fi

LOGFILE="${2:-logs/phase19_apply_sql_$(date +%Y%m%d_%H%M%S).log}"
mkdir -p "${LOGFILE:h}"
PG_CID="$(docker compose ps -q postgres 2>/dev/null | head -n 1 || true)"
if [[ -z "${PG_CID:-}" ]]; then
  PG_CID="$(docker ps --filter "status=running" --filter "name=postgres" --format '{{.ID}}' | head -n 1 || true)"
fi
if [[ -z "${PG_CID:-}" ]]; then
  PG_CID="$(docker ps --filter "status=running" --filter "name=motherboard" --format '{{.ID}} {{.Names}}' | rg -n 'postgres' | head -n 1 | awk '{print $1}' || true)"
fi

if [[ -z "${PG_CID:-}" ]]; then
  echo "error: postgres container not found."
  echo "hint: run: docker compose up -d"
  exit 2
fi

PG_USER="$(docker exec "$PG_CID" printenv POSTGRES_USER 2>/dev/null || true)"
PG_PASS="$(docker exec "$PG_CID" printenv POSTGRES_PASSWORD 2>/dev/null || true)"
PG_DB="$(docker exec "$PG_CID" printenv POSTGRES_DB 2>/dev/null || true)"

if [[ -z "${PG_USER:-}" || -z "${PG_PASS:-}" || -z "${PG_DB:-}" ]]; then
  echo "error: could not read POSTGRES_* env vars from container $PG_CID"
  docker inspect "$PG_CID" --format 'name={{.Name}} state={{.State.Status}} image={{.Config.Image}}' || true
  exit 2
fi

set +e
cat "$SQL_FILE" | docker exec -e PGPASSWORD="$PG_PASS" -i "$PG_CID" \
  psql -U "$PG_USER" -d "$PG_DB" -h 127.0.0.1 -p 5432 -v ON_ERROR_STOP=1 \
  2>&1 | tee "$LOGFILE"
RC=${pipestatus[2]:-1}
set -e

echo "log=$LOGFILE"
exit "$RC"
