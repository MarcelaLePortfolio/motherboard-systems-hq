export async function ensureRunView(pool) {
  if (!pool || typeof pool.query !== "function") {
    throw new Error("ensureRunView requires a pg pool with query()");
  }

  await pool.query(`drop view if exists run_view`);

  await pool.query(`
    create view run_view as
    with latest_event as (
      select distinct on (te.task_id)
        te.task_id::text as task_id,
        te.id::bigint as last_event_id,
        te.ts::bigint as last_event_ts,
        te.kind::text as last_event_kind,
        coalesce(te.actor, 'unassigned')::text as actor,
        te.run_id::text as run_id
      from task_events te
      order by te.task_id, te.ts desc, te.id desc
    ),
    terminal_event as (
      select distinct on (te.task_id)
        te.task_id::text as task_id,
        te.kind::text as terminal_event_kind,
        te.ts::bigint as terminal_event_ts,
        te.id::bigint as terminal_event_id
      from task_events te
      where te.kind in ('task.completed', 'task.failed', 'task.canceled')
      order by te.task_id, te.ts desc, te.id desc
    )
    select
      coalesce(le.run_id, t.run_id, t.task_id)::text as run_id,
      t.task_id::text as task_id,
      t.status::text as task_status,
      (t.status in ('completed', 'failed', 'canceled')) as is_terminal,
      le.last_event_id,
      le.last_event_ts,
      le.last_event_kind,
      coalesce(
        le.actor,
        t.payload->>'agent',
        t.payload->>'owner',
        t.payload->>'actor',
        'unassigned'
      )::text as actor,
      null::timestamptz as lease_expires_at,
      false as lease_fresh,
      null::bigint as lease_ttl_ms,
      null::bigint as last_heartbeat_ts,
      null::bigint as heartbeat_age_ms,
      te.terminal_event_kind,
      te.terminal_event_ts,
      te.terminal_event_id,
      t.id::text as id,
      t.status::text as status,
      t.updated_at,
      t.created_at,
      coalesce(
        t.payload->>'agent',
        t.payload->>'owner',
        t.payload->>'actor',
        'unassigned'
      )::text as agent
    from tasks t
    left join latest_event le on le.task_id = t.task_id
    left join terminal_event te on te.task_id = t.task_id
  `);
}
