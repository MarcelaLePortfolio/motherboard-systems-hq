import { appendTaskEvent } from "./task-events.mjs";

export async function dbDelegateTask(pool, body) {
  const title = body?.title || "(untitled)";
  const agent = body?.agent || "cade";
  const notes = body?.notes || "";
  const source = body?.source || "api";
  const traceId = body?.trace_id || body?.traceId || null;
  const meta = body?.meta ?? null;

  const r = await pool.query(
    `insert into tasks (title, agent, status, notes, source, trace_id, meta)
     values ($1, $2, 'queued', $3, $4, $5, $6)
     returning id::text, title, agent, status, notes, source, trace_id, error, meta, created_at, updated_at`,
    [title, agent, notes, source, traceId, meta]
  );

  await appendTaskEvent(pool, "task.created", { task_id: r.rows?.[0]?.id, ts: Date.now(), source });
  return r.rows[0];
}

export async function dbCompleteTask(pool, body) {
  const id = body?.taskId || body?.id;
  if (!id) throw new Error("taskId required");

  const status = body?.status || "done";
  const error = body?.error ?? null;
  const meta = body?.meta ?? null;

  const r = await pool.query(
    `update tasks
       set status = $2,
           error = $3,
           meta = coalesce($4, meta),
           updated_at = now()
     where id = $1::int
     returning id::text, title, agent, status, notes, source, trace_id, error, meta, created_at, updated_at`,
    [id, status, error, meta]
  );

  if (!r.rows[0]) throw new Error(`task not found: ${id}`);

  const row = r.rows[0];
  const k =
    String(row.status) === "done"
      ? "task.completed"
      : (String(row.status) === "failed" ? "task.failed" : "task.updated");

  await appendTaskEvent(pool, k, {
    task_id: row.id,
    status: row.status,
    error: row.error ?? null,
    source: body?.source || "api",
    ts: Date.now(),
  });

  return row;
}
