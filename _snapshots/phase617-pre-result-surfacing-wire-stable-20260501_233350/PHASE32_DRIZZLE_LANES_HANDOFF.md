# Phase 32 — Drizzle migrations split (SQLite lane + Postgres lane)

## Current state
- SQLite lane: `drizzle/` (SQLite-safe)
  - Runs clean:
    npx drizzle-kit migrate --config drizzle.config.json
- Postgres lane: `drizzle_pg/*.sql` (Postgres-only)
  - Config: drizzle.pg.config.json
  - Journal: drizzle_pg/meta/_journal.json
  - Runs clean:
    npx drizzle-kit migrate --config drizzle.pg.config.json

## Next step
Confirm where Drizzle tracks **Postgres** migrations in the database and commit any journal updates if present.

## Verification commands

### Locate PG migration tracking table
psql "$POSTGRES_URL" -c '\dt' | (grep -E 'drizzle|migration|journal' || true)
psql "$POSTGRES_URL" -c "\dt *.*drizzle*" || true
psql "$POSTGRES_URL" -c "\dt *.*migration*" || true

### Inspect contents (once identified)
psql "$POSTGRES_URL" -c 'select * from __drizzle_migrations order by 1 desc limit 50;' || true
psql "$POSTGRES_URL" -c 'select * from drizzle_migrations order by 1 desc limit 50;' || true
psql "$POSTGRES_URL" -c 'select * from migrations order by 1 desc limit 50;' || true

psql "$POSTGRES_URL" -c "
select table_schema, table_name
from information_schema.tables
where table_name ilike '%drizzle%'
   or table_name ilike '%migration%';
"

### Repo / journal check
git status --porcelain
git diff -- drizzle_pg/meta/_journal.json || true
git diff -- drizzle/meta/_journal.json || true

## Done criteria
- Identified PG migration tracking table and verified applied rows
- Any updated Drizzle journal committed (especially drizzle_pg/meta/_journal.json)
