WITH e AS (
  SELECT
    te.id AS event_id,
    te.task_id,
    te.run_id,
    regexp_replace(te.kind, '^task\.', '') AS kind,
    te.at
  FROM task_events te
),
k AS (
  SELECT
    task_id,
    run_id,
    event_id,
    at,
    kind,
    CASE WHEN kind IN ('completed','failed','canceled','cancelled') THEN 1 ELSE 0 END AS is_terminal,
    CASE WHEN kind = 'created' THEN 1 ELSE 0 END AS is_created,
    CASE WHEN kind = 'running' THEN 1 ELSE 0 END AS is_running
  FROM e
),
agg AS (
  SELECT
    task_id,
    max(run_id) FILTER (WHERE run_id IS NOT NULL) AS run_id_any,
    min(at) AS first_at,
    max(at) AS last_at,
    count(*)::int AS event_count,
    sum(is_created)::int AS created_count,
    sum(is_running)::int AS running_count,
    sum(is_terminal)::int AS terminal_count
  FROM k
  GROUP BY task_id
),
last_event AS (
  SELECT DISTINCT ON (task_id)
    task_id,
    kind AS last_kind,
    at   AS last_kind_at,
    event_id AS last_kind_event_id
  FROM k
  ORDER BY task_id, event_id DESC
),
first_created AS (
  SELECT DISTINCT ON (task_id)
    task_id,
    at AS created_at,
    event_id AS created_event_id
  FROM k
  WHERE is_created = 1
  ORDER BY task_id, event_id ASC
),
first_running AS (
  SELECT DISTINCT ON (task_id)
    task_id,
    at AS running_at,
    event_id AS running_event_id
  FROM k
  WHERE is_running = 1
  ORDER BY task_id, event_id ASC
),
first_terminal AS (
  SELECT DISTINCT ON (task_id)
    task_id,
    kind AS terminal_kind,
    at   AS terminal_at,
    event_id AS terminal_event_id
  FROM k
  WHERE is_terminal = 1
  ORDER BY task_id, event_id ASC
),
after_terminal AS (
  SELECT
    k.task_id,
    count(*)::int AS events_after_terminal
  FROM k
  JOIN first_terminal ft USING (task_id)
  WHERE k.event_id > ft.terminal_event_id
  GROUP BY k.task_id
),
issues AS (
  SELECT
    a.task_id,
    a.run_id_any AS run_id,
    a.first_at,
    a.last_at,
    a.event_count,
    a.created_count,
    a.running_count,
    a.terminal_count,
    le.last_kind,
    le.last_kind_at,
    ft.terminal_kind,
    ft.terminal_at,
    COALESCE(at2.events_after_terminal, 0) AS events_after_terminal,
    CASE
      WHEN a.created_count = 0 THEN 'MISSING_CREATED'
      WHEN a.created_count > 1 THEN 'MULTIPLE_CREATED'
      WHEN a.running_count > 1 THEN 'MULTIPLE_RUNNING'
      WHEN a.terminal_count > 1 THEN 'MULTIPLE_TERMINAL'
      WHEN ft.terminal_event_id IS NOT NULL AND fr.running_event_id IS NOT NULL AND ft.terminal_event_id < fr.running_event_id THEN 'TERMINAL_BEFORE_RUNNING'
      WHEN ft.terminal_event_id IS NOT NULL AND fc.created_event_id IS NOT NULL AND ft.terminal_event_id < fc.created_event_id THEN 'TERMINAL_BEFORE_CREATED'
      WHEN COALESCE(at2.events_after_terminal,0) > 0 THEN 'EVENTS_AFTER_TERMINAL'
      ELSE NULL
    END AS issue_code
  FROM agg a
  LEFT JOIN last_event le USING (task_id)
  LEFT JOIN first_created fc USING (task_id)
  LEFT JOIN first_running fr USING (task_id)
  LEFT JOIN first_terminal ft USING (task_id)
  LEFT JOIN after_terminal at2 USING (task_id)
)
SELECT
  task_id,
  run_id,
  first_at,
  last_at,
  event_count,
  created_count,
  running_count,
  terminal_count,
  last_kind,
  last_kind_at,
  terminal_kind,
  terminal_at,
  events_after_terminal,
  issue_code
FROM issues
WHERE issue_code IS NOT NULL
ORDER BY
  issue_code ASC,
  last_at DESC,
  last_kind_at DESC,
  task_id ASC;
