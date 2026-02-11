 SELECT DISTINCT ON (run_id) run_id,
    task_id,
    actor,
    lease_expires_at,
    lease_fresh,
    lease_ttl_ms,
    last_heartbeat_ts,
    heartbeat_age_ms,
    last_event_id,
    last_event_ts,
    last_event_kind,
    task_status,
    is_terminal,
    terminal_event_kind,
    terminal_event_ts,
    terminal_event_id
   FROM ( WITH last_event AS (
                 SELECT DISTINCT ON (te_1.task_id, te_1.run_id) te_1.task_id,
                    te_1.run_id,
                    te_1.id AS last_event_id,
                    te_1.ts AS last_event_ts,
                    te_1.kind AS last_event_kind,
                    te_1.actor AS last_event_actor
                   FROM task_events te_1
                  WHERE te_1.run_id IS NOT NULL
                  ORDER BY te_1.task_id, te_1.run_id, te_1.id DESC
                ), last_heartbeat AS (
                 SELECT te_1.task_id,
                    te_1.run_id,
                    max(te_1.ts) AS last_heartbeat_ts
                   FROM task_events te_1
                  WHERE te_1.run_id IS NOT NULL AND te_1.kind = 'heartbeat'::text
                  GROUP BY te_1.task_id, te_1.run_id
                ), terminal_event AS (
                 SELECT DISTINCT ON (te_1.task_id, te_1.run_id) te_1.task_id,
                    te_1.run_id,
                    regexp_replace(te_1.kind, '^task\.', '') AS terminal_event_kind,
                    te_1.ts AS terminal_event_ts,
                    te_1.id AS terminal_event_id
                   FROM task_events te_1
                  WHERE te_1.run_id IS NOT NULL AND (regexp_replace(te_1.kind, '^task\.', '') = ANY (ARRAY['completed'::text, 'failed'::text, 'canceled'::text, 'cancelled'::text, 'timeout'::text, 'timed_out'::text]))
                  ORDER BY te_1.task_id, te_1.run_id, te_1.id DESC
                )
         SELECT le.run_id,
            le.task_id,
            COALESCE(NULLIF(le.last_event_actor, ''::text), NULLIF(t.claimed_by, ''::text), NULLIF(t.actor, ''::text)) AS actor,
            t.lease_expires_at,
                CASE
                    WHEN t.lease_expires_at IS NULL THEN NULL::boolean
                    ELSE t.lease_expires_at::numeric > (EXTRACT(epoch FROM now()) * 1000.0)
                END AS lease_fresh,
                CASE
                    WHEN t.lease_expires_at IS NULL THEN NULL::bigint
                    ELSE GREATEST(0::numeric, t.lease_expires_at::numeric - EXTRACT(epoch FROM now()) * 1000.0)::bigint
                END AS lease_ttl_ms,
            lh.last_heartbeat_ts,
                CASE
                    WHEN lh.last_heartbeat_ts IS NULL THEN NULL::bigint
                    ELSE GREATEST(0::numeric, EXTRACT(epoch FROM now()) * 1000.0 - lh.last_heartbeat_ts::numeric)::bigint
                END AS heartbeat_age_ms,
            le.last_event_id,
            le.last_event_ts,
            le.last_event_kind,
            t.status AS task_status,
            t.status = ANY (ARRAY['completed'::text, 'failed'::text, 'canceled'::text, 'cancelled'::text]) AS is_terminal,
            te.terminal_event_kind,
            te.terminal_event_ts,
            te.terminal_event_id
           FROM last_event le
             LEFT JOIN tasks t ON t.task_id = le.task_id
             LEFT JOIN last_heartbeat lh ON lh.task_id = le.task_id AND lh.run_id = le.run_id
             LEFT JOIN terminal_event te ON te.task_id = le.task_id AND te.run_id = le.run_id) v
  ORDER BY run_id, last_event_ts DESC NULLS LAST, last_event_id DESC NULLS LAST;;
