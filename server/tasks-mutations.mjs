import { randomUUID } from "node:crypto";
import { emitTaskEvent } from "./task_events_emit.mjs";
import { assertNotEnforced } from "./policy/enforce.mjs";

function normalizeTaskId(body = {}) {
  return body?.task_id || body?.taskId || `task.${randomUUID()}`;
}

function normalizeTitle(body = {}) {
  return (
    body?.title ||
    body?.prompt ||
    body?.message ||
    body?.text ||
    body?.task ||
    "Delegated task"
  );
}

function buildPayload(body = {}) {
  return {
    agent: body?.agent || "cade",
    source: body?.source || "api",
    trace_id: body?.trace_id || body?.traceId || null,
    meta: body?.meta || null,
  };
}

export async function dbDelegateTask(pool, body = {}) {
  assertNotEnforced("tasks.mutations");

  const task_id = normalizeTaskId(body);
  const title = normalizeTitle(body);
  const status = "queued";
  const notes = body?.notes || "";
  const run_id = body?.run_id || body?.runId || null;
  const action_tier = body?.action_tier || body?.actionTier || "A";
  const kind = body?.kind || "delegated";
  const payload = buildPayload(body);

  const r = await pool.query(
    `insert into tasks (
      task_id,
      title,
      status,
      notes,
      run_id,
      action_tier,
      kind,
      payload
    )
    values ($1, $2, $3, $4, $5, $6, $7, $8::jsonb)
    returning
      id::text,
      task_id,
      title,
      status,
      notes,
      run_id,
      action_tier,
      kind,
      payload,
      created_at,
      updated_at`,
    [
      task_id,
      title,
      status,
      notes,
      run_id,
      action_tier,
      kind,
      JSON.stringify(payload),
    ],
  );

  const row = r.rows?.[0];

  await emitTaskEvent({
    pool,
    kind: "task.created",
    task_id: row?.task_id ?? task_id,
    actor: body?.actor ?? payload.source,
    payload: {
      source: payload.source,
      title: row?.title ?? title,
      target: payload.agent,
      status: row?.status ?? status,
      task: row ?? null,
      meta: payload.meta,
    },
  });

  return row;
}

export async function dbCompleteTask(pool, body = {}) {
  assertNotEnforced("tasks.mutations");

  const id = body?.task_id ?? body?.taskId ?? body?.id;
  const int_id = String(id || "").match(/^\d+$/) ? Number(id) : null;
  if (!id) throw new Error("taskId required");

  const status = body?.status || "done";
  const notePatch =
    body?.notes ??
    body?.error ??
    body?.message ??
    null;

  const r = await pool.query(
    `update tasks
       set status = $3,
           notes = coalesce($4, notes),
           updated_at = now()
     where (id = $1) or (task_id = $2)
     returning
       id::text,
       task_id,
       title,
       status,
       notes,
       run_id,
       action_tier,
       kind,
       payload,
       created_at,
       updated_at`,
    [int_id, String(id), status, notePatch],
  );

  if (!r.rows?.[0]) throw new Error(`task not found: ${id}`);

  const row = r.rows[0];
  const k = body?.kind ?? body?.event_kind ?? body?.eventKind ?? "task.event";
  const payload = row?.payload && typeof row.payload === "object" ? row.payload : {};

  await emitTaskEvent({
    pool,
    kind: k,
    task_id: row.task_id ?? row.id,
    actor: body?.actor ?? body?.source ?? "api",
    payload: {
      status: row.status,
      error: body?.error ?? null,
      source: body?.source || payload.source || "api",
      task: row,
    },
  });

  return row;
}
