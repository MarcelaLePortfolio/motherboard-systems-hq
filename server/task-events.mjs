/**
 * Legacy task_events schema in your docker DB:
 *   task_events(id bigint, kind text, payload text, created_at text)
 *
 * So we store payload as JSON string into the text column.
 *
 * SINGLE AUTHORITATIVE TASK EVENT WRITER — Phase 25 contract enforced.
 */

const __PHASE25_LIFECYCLE_KINDS = new Set([
  "task.created",
  "task.queued",
  "task.started",
  "task.progress",
  "task.completed",
  "task.failed",
  "task.canceled",
]);

const __PHASE25_TERMINAL_KINDS = new Set([
  "task.completed",
  "task.failed",
  "task.canceled",
]);

function __phase25_taskIdFromObj(obj) {
  return obj?.task_id ?? obj?.taskId ?? obj?.task?.id ?? null;
}
export async function appendTaskEvent(pool, kind, task_id, payload, opts = undefined) {
  pool = pool || globalThis.__DB_POOL;
  if (!pool) throw new Error("appendTaskEvent: missing pool");
  // Phase25 contract: server is the single authoritative writer of task_events.
  // IMPORTANT: callers historically pass (pool, kind, payloadObj). We keep that shape.
  // - If `task_id` is actually the payload (object/string) we treat it as payload and infer task_id.
  // - pool may be omitted; we fall back to globalThis.__DB_POOL.

  const o = (opts && typeof opts === "object") ? opts : {};
  const now = Date.now();

  // Back-compat: appendTaskEvent(pool, kind, payloadObj)
  let payloadIn = payload;
  let taskIdIn = task_id;

  if (payload === undefined && task_id !== undefined && task_id !== null) {
    // called as (pool, kind, payload)
    payloadIn = task_id;
    taskIdIn = null;
  }

  // pool resolution
  if (!pool || typeof pool.query !== "function") {
    throw new Error("phase25: appendTaskEvent missing pool");
  }

  const actor =
    (o.actor && String(o.actor)) ||
    process.env.PHASE26_WORKER_ACTOR ||
    process.env.WORKER_OWNER ||
    "server";

  const run_id = (o.run_id === undefined) ? null : o.run_id;
  const ts = Number.isFinite(o.ts) ? Number(o.ts) : now;

  // Normalize kind + task_id
  const k = String(kind || "");

  function __phase25_taskIdFromObj(obj) {
    return obj?.task_id ?? obj?.taskId ?? obj?.task?.id ?? null;
  }

  const inferredTaskId =
    (taskIdIn == null ? __phase25_taskIdFromObj(payloadIn) : taskIdIn);

  // payload text + jsonb (best-effort parse)
  let payloadText = "";
  let payloadJson = null;

  try {
    if (payloadIn === null || payloadIn === undefined) payloadText = "";
    else if (typeof payloadIn === "string") payloadText = payloadIn;
    else payloadText = JSON.stringify(payloadIn);
  } catch (e) {
payloadText = String(payloadIn);
  }

  if (o.payload !== undefined) {
    payloadJson = o.payload;
  } else if (payloadIn && typeof payloadIn === "object") {
    payloadJson = payloadIn;
  } else if (typeof payloadText === "string" && payloadText.length) {
    try { payloadJson = JSON.parse(payloadText); } catch (e) {
payloadJson = null; }
  }
  if (payloadJson === undefined) payloadJson = null;

  // Phase 25: Exact-dupe idempotency — if exact (kind,payload) already exists, do nothing.
  try {
    const dup = await pool.query(
  "insert into task_events(kind, task_id, run_id, actor, ts, payload) values ($1::text, $2::text, $3::text, $4::text, $5::bigint, $6::jsonb)",
  [k, (inferredTaskId == null ? null : String(inferredTaskId)), run_id, actor, ts, payloadJson]
);
}



