export async function appendTaskEvent(pool, kind, payload) {
  if (!pool) throw new Error("appendTaskEvent requires pool");

  const p = payload ?? {};

  // Support both Phase19 schema (type/meta fields) and the earlier (kind/payload) schema by writing
  // to the Phase19 table shape. If your table uses (kind,payload) only, this will fail loudly and we’ll adapt.
  const taskId = p?.task_id ?? p?.taskId ?? null;
  const ts = p?.ts ?? Date.now();
  const runId = p?.run_id ?? p?.runId ?? null;
  const actor = p?.actor ?? null;

  const meta = { ...p };
  delete meta.task_id;
  delete meta.taskId;
  delete meta.ts;
  delete meta.run_id;
  delete meta.runId;
  delete meta.actor;

  await pool.query(
    `insert into task_events (task_id, type, ts, run_id, actor, meta)
     values ($1::int, $2::text, $3::bigint, $4::text, $5::text, $6::jsonb)`,
    [taskId, kind, ts, runId, actor, meta]
  );
}
