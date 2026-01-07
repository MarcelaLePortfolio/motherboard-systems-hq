#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "=== Phase 19 Tasks/Postgres Doctor ==="
echo "pwd: $PWD"
echo

echo "== git =="
git --no-pager log -1 --oneline || true
git status --porcelain || true
echo

echo "== docker: motherboard-postgres =="
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | rg -n 'motherboard-postgres|NAMES' || true
echo

if docker ps --format '{{.Names}}' | rg -q '^motherboard-postgres$'; then
  echo "== postgres env (inside container) =="
  docker exec motherboard-postgres bash -lc 'env | rg -n "^POSTGRES_(USER|PASSWORD|DB)=" || true'
  echo
  echo "== postgres smoke test =="
  docker exec motherboard-postgres bash -lc '
    set -euo pipefail
    U="${POSTGRES_USER:-postgres}"
    D="${POSTGRES_DB:-postgres}"
    echo "psql -U $U -d $D -c \"select 1\""
    psql -U "$U" -d "$D" -c "select 1" >/dev/null
    echo "OK"
  '
else
  echo "motherboard-postgres is not running. Start it first (docker compose up -d)."
  exit 2
fi
echo

echo "== derive DATABASE_URL from container env =="
PG_USER="$(docker exec motherboard-postgres bash -lc 'echo "${POSTGRES_USER:-postgres}"')"
PG_DB="$(docker exec motherboard-postgres bash -lc 'echo "${POSTGRES_DB:-postgres}"')"
PG_PASS="$(docker exec motherboard-postgres bash -lc 'echo "${POSTGRES_PASSWORD:-postgres}"')"
DB_URL="postgres://${PG_USER}:${PG_PASS}@127.0.0.1:5432/${PG_DB}"
echo "DATABASE_URL=${DB_URL}"
echo

echo "== write .env.local (gitignored) =="
cat > .env.local <<ENVEOF
DATABASE_URL=${DB_URL}
POSTGRES_URL=${DB_URL}
ENVEOF
echo "wrote .env.local"
echo

echo "== locate tasks api + db wiring =="
echo "-- files mentioning /api/tasks --"
rg -n "/api/tasks" -S . || true
echo
echo "-- files mentioning tasks table/schema --"
rg -n "tasks(_|\\b)|task\\b" server src app db drizzle prisma -S . 2>/dev/null || true
echo
echo "-- files mentioning DATABASE_URL / POSTGRES_URL --"
rg -n "DATABASE_URL|POSTGRES_URL" -S server src app db drizzle prisma . 2>/dev/null || true
echo

echo "== npm scripts (db/migrate) =="
npm -s run | rg -n "drizzle|migrat|db:" || true
echo

echo "== attempt migration (common script names) =="
set +e
npm -s run db:migrate
RC=$?
set -e
if [ "$RC" -ne 0 ]; then
  echo
  echo "db:migrate failed or missing. Trying drizzle-kit migrate if available..."
  if npx --yes drizzle-kit --help >/dev/null 2>&1; then
    npx --yes drizzle-kit migrate
  else
    echo "drizzle-kit not available. Add/verify migration tooling in package.json."
    exit 3
  fi
fi
echo

echo "== quick DB check: list public tables =="
docker exec motherboard-postgres bash -lc '
  set -euo pipefail
  U="${POSTGRES_USER:-postgres}"
  D="${POSTGRES_DB:-postgres}"
  psql -U "$U" -d "$D" -c "\\dt" || true
'
echo

echo "DONE."
