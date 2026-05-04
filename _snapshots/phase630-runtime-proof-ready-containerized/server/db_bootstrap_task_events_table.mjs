export async function ensureTaskEventsTable(pool) {
  if (!pool || typeof pool.query !== "function") {
    throw new Error("ensureTaskEventsTable requires a pg pool with query()");
  }

  await pool.query(`
    create table if not exists task_events (
      id bigint generated always as identity primary key,
      task_id text,
      kind text not null,
      actor text,
      payload jsonb not null default '{}'::jsonb,
      run_id text,
      created_at timestamptz not null default now(),
      ts bigint not null default (extract(epoch from now()) * 1000)::bigint
    )
  `);

  await pool.query(`
    create index if not exists idx_task_events_ts
    on task_events (ts asc, id asc)
  `);

  await pool.query(`
    create index if not exists idx_task_events_task_id
    on task_events (task_id)
  `);

  await pool.query(`
    create index if not exists idx_task_events_kind
    on task_events (kind)
  `);
}
