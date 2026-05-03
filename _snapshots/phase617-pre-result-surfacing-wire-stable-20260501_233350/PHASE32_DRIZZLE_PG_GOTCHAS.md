# Phase 32 — Drizzle PG lane gotchas (so we don’t re-learn this)

## 1) Schema-qualified tracking table
- Drizzle tracks Postgres migrations in: `drizzle.__drizzle_migrations`
- If you query without schema, you’ll get `relation "__drizzle_migrations" does not exist`.

## 2) Empty journal == “success” with zero tracking
- If `drizzle_pg/meta/_journal.json` has `"entries": []`, `drizzle-kit migrate` may print success but won’t insert rows.

## 3) Journal tag must NOT include ".sql"
- Drizzle expects journal `tag` like `0001_create_task_events` (no `.sql`)
- If journal tag includes `.sql`, Drizzle will look for `*.sql.sql` and error.

## 4) zsh history expansion vs SQL regex operator
- In zsh, `!` can trigger history expansion (breaks `!~`).
- Use: `setopt NO_BANG_HIST` before running `psql -c "... !~ ..."`.

## Current invariant
- drizzle_pg lane is now fully versioned and tracked:
  - Files: `drizzle_pg/*.sql`
  - Journal: `drizzle_pg/meta/_journal.json`
  - DB tracking: `drizzle.__drizzle_migrations` has one row per migration hash
