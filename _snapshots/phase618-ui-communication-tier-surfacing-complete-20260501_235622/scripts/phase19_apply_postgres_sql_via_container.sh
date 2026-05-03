
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SQL_FILE="${1:-}"
if [[ -z "${SQL_FILE}" || ! -f "${SQL_FILE}" ]]; then
  echo "usage: $0 <sql-file-path-on-host> [logfile] [compose-service-name]"
  echo "error: missing or unreadable SQL_FILE: ${SQL_FILE:-<empty>}"
  exit 2
fi

LOGFILE="${2:-logs/phase19_apply_sql_$(date +%Y%m%d_%H%M%S).log}"
mkdir -p "$(dirname "$LOGFILE")"

SVC="${3:-}"
if [[ -z "${SVC}" ]]; then
  SVC="$(docker compose config --services 2>/dev/null | rg -n 'postgres' | head -n 1 | sed -E 's/^[0-9]+://')"
fi
if [[ -z "${SVC}" ]]; then
  # fallback guess
  SVC="postgres"
fi

PG_CID="$(docker compose ps -q "$SVC" 2>/dev/null | head -n 1 || true)"
if [[ -z "${PG_CID:-}" ]]; then
  echo "error: could not resolve container id for compose service: $SVC"
  echo "hint: docker compose config --services"
  exit 2
fi

PG_USER="$(docker exec "$PG_CID" printenv POSTGRES_USER 2>/dev/null || true)"
PG_PASS="$(docker exec "$PG_CID" printenv POSTGRES_PASSWORD 2>/dev/null || true)"
PG_DB="$(docker exec "$PG_CID" printenv POSTGRES_DB 2>/dev/null || true)"

if [[ -z "${PG_USER:-}" || -z "${PG_PASS:-}" || -z "${PG_DB:-}" ]]; then
  echo "error: could not read POSTGRES_* env vars from container: $PG_CID (service: $SVC)"
  docker inspect "$PG_CID" --format 'name={{.Name}} state={{.State.Status}} image={{.Config.Image}}' || true
  exit 2
fi

set +e
cat "$SQL_FILE" | docker exec -e PGPASSWORD="$PG_PASS" -i "$PG_CID" \
  psql -U "$PG_USER" -d "$PG_DB" -h 127.0.0.1 -p 5432 -v ON_ERROR_STOP=1 \
  2>&1 | tee "$LOGFILE"
RC=${PIPESTATUS[2]:-1}
set -e

echo "log=$LOGFILE"
exit "$RC"
