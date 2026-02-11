-- Phase 37.0 (Planning Only)
-- Acceptance-check SQL definitions for the Run Timeline Integrity contract.
-- NO mutations. Read-only queries only.

-- =========================
-- 0) Helpers / Notes
-- =========================
-- Canonical ordering key (required for Phase 37):
--   ORDER BY task_events.ts ASC, task_events.id ASC
--
-- Expected schema:
--   public.task_events(id bigint, ts bigint, kind text, task_id text, run_id text, actor text, payload_jsonb jsonb, ...)
--   public.run_view(...)
--
-- If your task_events uses different column names, adjust locally.
--
-- Recommended usage:
--   docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f PHASE37_ACCEPTANCE_CHECKS.sql

\pset pager off
\timing on

-- =========================
-- 1) Sanity: run_view exists
-- =========================
SELECT 'run_view rowcount' AS check, count(*) AS n
FROM public.run_view;

-- =========================
-- 2) Ordering determinism check
--    Ensure that for a given run_id, (ts,id) is a total order and that
--    "last_event_{ts,id}" matches the max by canonical ordering.
-- =========================

-- 2a) Identify any run_id where the event with max(ts,id) disagrees with run_view.last_event_{ts,id}
WITH last_ev AS (
  SELECT DISTINCT ON (run_id)
    run_id,
    id AS ev_id,
    ts AS ev_ts,
    kind AS ev_kind
  FROM public.task_events
  WHERE run_id IS NOT NULL
  ORDER BY run_id, ts DESC, id DESC
)
SELECT
  'ordering_last_event_mismatch' AS check,
  rv.run_id,
  rv.last_event_ts,
  rv.last_event_id,
  le.ev_ts AS expected_last_event_ts,
  le.ev_id AS expected_last_event_id,
  rv.last_event_kind,
  le.ev_kind AS expected_last_event_kind
FROM public.run_view rv
JOIN last_ev le USING (run_id)
WHERE (rv.last_event_ts IS DISTINCT FROM le.ev_ts)
   OR (rv.last_event_id IS DISTINCT FROM le.ev_id)
   OR (rv.last_event_kind IS DISTINCT FROM le.ev_kind)
ORDER BY rv.run_id
LIMIT 50;

-- 2b) Surface ties on ts for the same run_id (not a failure by itself, but must be tie-broken by id)
SELECT
  'ts_ties_per_run' AS check,
  run_id,
  ts,
  count(*) AS n
FROM public.task_events
WHERE run_id IS NOT NULL
GROUP BY run_id, ts
HAVING count(*) > 1
ORDER BY n DESC, run_id, ts
LIMIT 50;

-- =========================
-- 3) Traceability spot-audit query (parameterized pattern)
--    Pick a run_id and inspect the ordered event timeline.
-- =========================

-- 3a) Replace 'r1' with a real run_id when you run the audit.
--     This shows the canonical timeline for the run.
--     NOTE: This is a template query; it returns 0 rows until you set the run_id.
SELECT
  'timeline' AS section,
  id,
  ts,
  kind,
  task_id,
  run_id,
  actor
FROM public.task_events
WHERE run_id = 'REPLACE_ME_RUN_ID'
ORDER BY ts ASC, id ASC
LIMIT 200;

-- 3b) Snapshot row for same run_id (compare against timeline above)
SELECT
  'snapshot' AS section,
  *
FROM public.run_view
WHERE run_id = 'REPLACE_ME_RUN_ID';

-- =========================
-- 4) Snapshot coherence checks
--    Validate terminal fields align to terminal event, if any.
-- =========================

-- 4a) Terminal event, by canonical ordering, for each run_id (if present)
WITH terminal AS (
  SELECT DISTINCT ON (run_id)
    run_id,
    id AS term_id,
    ts AS term_ts,
    kind AS term_kind
  FROM public.task_events
  WHERE run_id IS NOT NULL
    AND kind IN ('completed','failed','canceled','cancelled')
  ORDER BY run_id, ts DESC, id DESC
)
SELECT
  'terminal_mismatch' AS check,
  rv.run_id,
  rv.terminal_event_kind,
  rv.terminal_event_ts,
  rv.terminal_event_id,
  t.term_kind AS expected_terminal_kind,
  t.term_ts   AS expected_terminal_ts,
  t.term_id   AS expected_terminal_id
FROM public.run_view rv
JOIN terminal t USING (run_id)
WHERE (rv.terminal_event_kind IS DISTINCT FROM t.term_kind)
   OR (rv.terminal_event_ts IS DISTINCT FROM t.term_ts)
   OR (rv.terminal_event_id IS DISTINCT FROM t.term_id)
ORDER BY rv.run_id
LIMIT 50;

-- 4b) If run_view says is_terminal=true, ensure a terminal event exists.
SELECT
  'is_terminal_without_terminal_event' AS check,
  rv.run_id,
  rv.is_terminal,
  rv.terminal_event_kind,
  rv.terminal_event_ts,
  rv.terminal_event_id
FROM public.run_view rv
LEFT JOIN LATERAL (
  SELECT 1 AS has_term
  FROM public.task_events te
  WHERE te.run_id = rv.run_id
    AND te.kind IN ('completed','failed','canceled','cancelled')
  LIMIT 1
) x ON true
WHERE rv.is_terminal = true
  AND x.has_term IS NULL
ORDER BY rv.run_id
LIMIT 50;

-- =========================
-- 5) Lease/heartbeat coherence (informational)
--    These are "derived" values; ensure they are explainable by definition.
-- =========================

-- 5a) Quick look at runs where lease_fresh=false but ttl still positive (if that should be impossible)
SELECT
  'lease_fresh_vs_ttl' AS check,
  run_id,
  lease_expires_at,
  lease_fresh,
  lease_ttl_ms
FROM public.run_view
WHERE lease_expires_at IS NOT NULL
  AND lease_ttl_ms IS NOT NULL
  AND lease_fresh = false
  AND lease_ttl_ms > 0
ORDER BY lease_ttl_ms DESC
LIMIT 50;

-- 5b) Quick look at negative heartbeat_age_ms (should not happen if derived from now-ts correctly)
SELECT
  'negative_heartbeat_age' AS check,
  run_id,
  last_heartbeat_ts,
  heartbeat_age_ms
FROM public.run_view
WHERE heartbeat_age_ms IS NOT NULL
  AND heartbeat_age_ms < 0
ORDER BY heartbeat_age_ms
LIMIT 50;

\timing off
