import { emitTaskEvent } from "./task_events_emit.mjs";

import { assertNotEnforced } from "./policy/enforce.mjs";

export async function dbDelegateTask(pool, body) {
  // Phase50: DB write-path enforcement (tasks)
  assertNotEnforced("tasks.mutations");

  const title = body?.title || "(untitled)";
  const agent = body?.agent || "cade";
  const notes = body?.notes || "";
  const source = body?.source || "api";
  const traceId = body?.trace_id || body?.traceId || null;
  const meta = body?.meta ?? null;

  const task_id = body?.task_id ?? body?.taskId ?? null;

  const r = await pool.query(
    `insert into tasks (task_id, title, agent, status, notes, source, trace_id, meta)
     values ($1, $2, $3, 'queued', $4, $5, $6, $7)
     returning id::text, task_id, title, agent, status, notes, source, trace_id, error, meta, created_at, updated_at`,
    [task_id, title, agent, notes, source, traceId, meta]
  );

  const row = r.rows?.[0];
  await emitTaskEvent({
    pool,
    kind: "task.created",
    task_id: row?.task_id ?? row?.id ?? null,
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
  // Phase50: DB write-path enforcement (tasks)
  assertNotEnforced("tasks.mutations");

  const id = body?.task_id ?? body?.taskId ?? body?.id;
  const int_id = (String(id).match(/^\d+$/) ? Number(id) : null);
  if (!id) throw new Error("taskId required");

  const status = body?.status || "done";
  const error = body?.error ?? null;
  const meta = body?.meta ?? null;

  const r = await pool.query(
    `update tasks
       set status = $3,
           error = $4,
           meta = coalesce($5, meta),
           updated_at = now()
     where (id = $1) OR (task_id = $2)
     returning id::text, task_id, title, agent, status, notes, source, trace_id, error, meta, created_at, updated_at`,
    [int_id, String(id), status, error, meta]
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
    task_id: row.task_id ?? row.id,
    actor: body?.actor ?? (body?.source || "api"),
    payload: {
      status: row.status,
      error: row.error ?? null,
      source: body?.source || "api",
    },
  });

  return row;
}
