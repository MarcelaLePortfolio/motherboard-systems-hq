-- Phase 36.2 — Run Observability (read-only surface)
-- Enforce "1 row per run_id" at the view layer (no app logic, no writes).
-- Strategy:
--   1) Capture the existing run_view definition via pg_get_viewdef(...)
--   2) Sanitize: remove any trailing semicolons so it can be embedded as a subquery
--   3) Wrap it in SELECT DISTINCT ON (run_id) with stable ordering using columns on run_view:
--        last_event_ts DESC, last_event_id DESC
--
-- Notes:
-- - No tables/columns are created.
-- - View-only change; API remains a single SELECT from run_view.

DO $$
DECLARE
  v_def text;
BEGIN
  PERFORM 1
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname='public' AND c.relname='run_view' AND c.relkind='v';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'public.run_view does not exist';
  END IF;

  v_def := pg_get_viewdef('public.run_view'::regclass, true);

  -- IMPORTANT: pg_get_viewdef may include a trailing semicolon; strip it for embedding.
  v_def := regexp_replace(v_def, ';\s*$', '', 'g');

  EXECUTE format(
    'CREATE OR REPLACE VIEW public.run_view AS
     SELECT DISTINCT ON (run_id) *
     FROM (%s) v
     ORDER BY run_id, last_event_ts DESC NULLS LAST, last_event_id DESC NULLS LAST',
    v_def
  );
END $$;
