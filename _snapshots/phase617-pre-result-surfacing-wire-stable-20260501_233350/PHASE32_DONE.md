# Phase 32 — DONE ✅ (Drizzle migrations split: SQLite + Postgres lanes)

## Outcome
- **SQLite lane**: `drizzle/` runs clean with `drizzle.config.json`
  - `npx drizzle-kit migrate --config drizzle.config.json`
- **Postgres lane**: `drizzle_pg/` runs clean with `drizzle.pg.config.json`
  - `npx drizzle-kit migrate --config drizzle.pg.config.json`

## Confirmed Postgres migration tracking
- Tracking table: `drizzle.__drizzle_migrations`
- Verified: **3 rows** present.

## Key gotchas captured
- Schema-qualified table name (`drizzle.__drizzle_migrations`)
- PG journal must have entries (empty entries => “success” but no tracking)
- Journal tags must not include `.sql` (prevents `.sql.sql` lookup)
- zsh history expansion can break `!~` unless `setopt NO_BANG_HIST`

## Proof command set
- `npx drizzle-kit migrate --config drizzle.config.json`
- `npx drizzle-kit migrate --config drizzle.pg.config.json`
- `psql "$POSTGRES_URL" -c "select count(*) from drizzle.__drizzle_migrations;"`
