
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 FRESH SYSTEM RESET SCHEMA-AWARE ====="

DB_USER="$(docker compose exec -T postgres printenv POSTGRES_USER | tr -d '\r')"

DB_NAME="$(docker compose exec -T postgres printenv POSTGRES_DB | tr -d '\r')"

if [ -z "$DB_USER" ]; then DB_USER="postgres"; fi

if [ -z "$DB_NAME" ]; then DB_NAME="postgres"; fi

echo ""

echo "[1] Using database"

echo "DB_USER=$DB_USER"

echo "DB_NAME=$DB_NAME"

echo ""

echo "[2] Existing public tables"

docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -c "

SELECT tablename

FROM pg_tables

WHERE schemaname = 'public'

ORDER BY tablename;

"

echo ""

echo "[3] Current counts for reset-relevant tables"

docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -c "

SELECT table_name, row_count

FROM (

  SELECT 'tasks' AS table_name, CASE WHEN to_regclass('public.tasks') IS NULL THEN NULL ELSE (SELECT COUNT(*) FROM tasks) END AS row_count

  UNION ALL

  SELECT 'task_events', CASE WHEN to_regclass('public.task_events') IS NULL THEN NULL ELSE (SELECT COUNT(*) FROM task_events) END

  UNION ALL

  SELECT 'guidance', CASE WHEN to_regclass('public.guidance') IS NULL THEN NULL ELSE (SELECT COUNT(*) FROM guidance) END

  UNION ALL

  SELECT 'guidance_history', CASE WHEN to_regclass('public.guidance_history') IS NULL THEN NULL ELSE (SELECT COUNT(*) FROM guidance_history) END

  UNION ALL

  SELECT 'runs', CASE WHEN to_regclass('public.runs') IS NULL THEN NULL ELSE (SELECT COUNT(*) FROM runs) END

) s

ORDER BY table_name;

"

echo ""

echo "[4] Truncate only tables that exist"

docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" <<'SQL'

DO $$

DECLARE

  tables_to_clear text[] := ARRAY['task_events', 'guidance_history', 'guidance', 'tasks', 'runs'];

  t text;

BEGIN

  FOREACH t IN ARRAY tables_to_clear LOOP

    IF to_regclass('public.' || t) IS NOT NULL THEN

      EXECUTE format('TRUNCATE TABLE public.%I RESTART IDENTITY CASCADE', t);

      RAISE NOTICE 'truncated %', t;

    ELSE

      RAISE NOTICE 'skipped missing table %', t;

    END IF;

  END LOOP;

END $$;

SQL

echo ""

echo "[5] Verify reset counts"

docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -c "

SELECT table_name, row_count

FROM (

  SELECT 'tasks' AS table_name, CASE WHEN to_regclass('public.tasks') IS NULL THEN NULL ELSE (SELECT COUNT(*) FROM tasks) END AS row_count

  UNION ALL

  SELECT 'task_events', CASE WHEN to_regclass('public.task_events') IS NULL THEN NULL ELSE (SELECT COUNT(*) FROM task_events) END

  UNION ALL

  SELECT 'guidance', CASE WHEN to_regclass('public.guidance') IS NULL THEN NULL ELSE (SELECT COUNT(*) FROM guidance) END

  UNION ALL

  SELECT 'guidance_history', CASE WHEN to_regclass('public.guidance_history') IS NULL THEN NULL ELSE (SELECT COUNT(*) FROM guidance_history) END

  UNION ALL

  SELECT 'runs', CASE WHEN to_regclass('public.runs') IS NULL THEN NULL ELSE (SELECT COUNT(*) FROM runs) END

) s

ORDER BY table_name;

"

echo ""

echo "[6] Restart runtime"

docker compose up -d dashboard worker

sleep 8

docker compose ps

echo ""

echo "[7] API verification"

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks

echo ""

echo "[8] Commit reset helpers"

git add PHASE719_FRESH_SYSTEM_RESET.sh PHASE719_FRESH_SYSTEM_RESET_RETRY.sh PHASE719_FRESH_SYSTEM_RESET_SCHEMA_AWARE.sh

git commit -m "Phase 719: reset demo execution history with schema-aware cleanup" || true

git push origin dev

echo ""

echo "===== PHASE 719 FRESH SYSTEM RESET SCHEMA-AWARE COMPLETE ====="

