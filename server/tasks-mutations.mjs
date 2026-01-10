import { emitTaskEvent } from "./task_events_emit.mjs";

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

  const row = r.rows?.[0];
  await emitTaskEvent({
    pool,
    kind: "task.created",
    task_id: row?.id ?? null,
    actor: body?.actor ?? source,
    payload: {
        source,
        title: row?.title ?? null,
        target: row?.agent ?? null,
        status: row?.status ?? "queued",
        task: row ?? null,
        meta: row?.meta ?? null,
      },
  });

  return row;
}

export async function dbCompleteTask(pool, body) {
  const id = body?.task_id ?? body?.taskId ?? body?.id;
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
    // Phase 25: FORBIDDEN — do not derive lifecycle kind from task status.
    // Caller may supply a canonical kind; otherwise emit a non-lifecycle event.
    const k =
      body?.kind ??
      body?.event_kind ??
      body?.eventKind ??
      "task.event";


  await emitTaskEvent({
    pool,
    kind: k,
    task_id: row.id,
    actor: body?.actor ?? (body?.source || "api"),
    payload: {
      status: row.status,
      error: row.error ?? null,
      source: body?.source || "api",
    },
  });

  return row;
}
