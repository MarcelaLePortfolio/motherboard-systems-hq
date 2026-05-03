
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "=== Phase 19 Tasks/Postgres Doctor ==="
echo "pwd: $(pwd)"
echo

echo "== git =="
git --no-pager log -1 --oneline
git status --porcelain
echo

echo "== docker: postgres containers =="
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | rg -n '(postgres|motherboard-postgres|NAMES)' || true
echo

PG_CID="$(docker compose ps -q postgres 2>/dev/null | head -n 1 || true)"
if [[ -z "${PG_CID:-}" ]]; then
  PG_CID="$(docker ps --filter "status=running" --filter "name=postgres" --format '{{.ID}}' | head -n 1 || true)"
fi

if [[ -z "${PG_CID:-}" ]]; then
  echo "No running Postgres container found. Start it first (docker compose up -d)."
  exit 2
fi

PG_NAME="$(docker inspect -f '{{.Name}}' "$PG_CID" 2>/dev/null | sed 's#^/##' || true)"
PG_STATE="$(docker inspect -f '{{.State.Status}}' "$PG_CID" 2>/dev/null || true)"

echo "== docker: selected postgres container =="
echo "id:    $PG_CID"
echo "name:  ${PG_NAME:-<unknown>}"
echo "state: ${PG_STATE:-<unknown>}"
echo

if [[ "${PG_STATE:-}" != "running" ]]; then
  echo "Selected Postgres container is not running. Start it first (docker compose up -d)."
  exit 2
fi

echo "== postgres env (inside container) =="
docker exec "$PG_CID" env | rg -n '^POSTGRES_' || true
echo

echo "== node deps =="
node -v
npm -v
echo

echo "== check: pg dependency installed in repo =="
node -e "require.resolve('pg'); console.log('pg: OK')"
echo

echo "== check: DATABASE_URL/POSTGRES_URL present =="
if [[ -z "${DATABASE_URL:-}" && -z "${POSTGRES_URL:-}" ]]; then
  echo "Missing DATABASE_URL/POSTGRES_URL env var."
  exit 2
fi
echo "OK"
echo

echo "== check: can connect + see tasks + task_events (via node/pg) =="
node - <<'NODE'
const pg = require("pg");
const url =
  process.env.DATABASE_URL ||
  process.env.POSTGRES_URL ||
  process.env.POSTGRES_URI ||
  process.env.POSTGRES_CONNECTION_STRING;

if (!url) { console.error("Missing DATABASE_URL/POSTGRES_URL env var."); process.exit(2); }

(async () => {
  const c = new pg.Client({ connectionString: url });
  await c.connect();

  const who = await c.query("select current_database() as db, current_user as usr;");
  const tasks = await c.query("select to_regclass('public.tasks') as reg;");
  const te = await c.query("select to_regclass('public.task_events') as reg;");

  console.log(JSON.stringify({
    ok: true,
    whoami: who.rows[0],
    tasks: tasks.rows[0].reg,
    task_events: te.rows[0].reg
  }, null, 2));

  if (!te.rows[0].reg) {
    console.error("task_events missing in Postgres. Create it before proceeding.");
    process.exit(2);
  }

  // warn-only: column nullability
  const cols = await c.query(`
    select column_name, is_nullable, data_type
    from information_schema.columns
    where table_schema='public' and table_name='task_events'
    order by ordinal_position;
  `);
  const byName = Object.fromEntries(cols.rows.map(r => [r.column_name, r]));
  const warn = [];
  for (const k of ["kind","payload"]) {
    if (byName[k] && String(byName[k].is_nullable).toUpperCase() === "YES") warn.push(`${k} is nullable`);
  }
  if (warn.length) console.log("WARN:", warn.join("; "));

  await c.end();
})().catch(e => { console.error("connect/check failed:", e?.message || e); process.exit(2); });
NODE
echo

echo "== doctor OK =="
