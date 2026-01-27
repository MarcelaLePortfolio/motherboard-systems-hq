# Phase 32 — Postgres Drizzle tracking (confirmed)

## What Drizzle uses on Postgres
- Tracking table: `drizzle.__drizzle_migrations`
  - Columns: `id (serial)`, `hash (text)`, `created_at (bigint)`
- Verified present in DB: `postgres` on `postgres://postgres:postgres@127.0.0.1:5432/postgres`

## Fix applied
- `drizzle_pg/meta/_journal.json` originally had empty `entries: []`, so `drizzle-kit migrate` reported success but recorded nothing.
- Populated `drizzle_pg/meta/_journal.json` with entries for each `drizzle_pg/*.sql` migration.
- Corrected journal `tag` values to exclude the `.sql` suffix (prevents `.sql.sql` lookup).
- Seeded `drizzle.__drizzle_migrations` with one row per migration hash.
- Result: `drizzle.__drizzle_migrations` now has 3 rows and subsequent PG migrates run clean.

## Commands to verify later
- `psql "$POSTGRES_URL" -c "\dt drizzle.*"`
- `psql "$POSTGRES_URL" -c "select * from drizzle.__drizzle_migrations order by id;"`
- `cat drizzle_pg/meta/_journal.json`
