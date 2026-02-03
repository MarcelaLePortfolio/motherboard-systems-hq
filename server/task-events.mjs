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
export async function appendTaskEvent(kind, task_id, payload, opts = undefined) {
  // Phase25 contract: server is the single authoritative writer of task_events.
  const o = (opts && typeof opts === "object") ? opts : {};
  const now = Date.now();

  // Preserve legacy normalization used elsewhere in this file.
  const k = String(kind || "");
  const taskId = (task_id == null ? __phase25_taskIdFromObj(payload) : task_id);

  const actor =
    (o.actor && String(o.actor)) ||
    process.env.PHASE26_WORKER_ACTOR ||
    process.env.WORKER_OWNER ||
    "server";

  const run_id = (o.run_id === undefined) ? null : o.run_id;
  const ts = Number.isFinite(o.ts) ? Number(o.ts) : now;

  // payload text + jsonb (best-effort parse)
  let payloadText = "";
  let payloadJson = null;

  try {
    if (payload === null || payload === undefined) payloadText = "";
    else if (typeof payload === "string") payloadText = payload;
    else payloadText = JSON.stringify(payload);
  } catch {
    payloadText = String(payload);
  }

  if (o.payload_jsonb !== undefined) {
    payloadJson = o.payload_jsonb;
  } else if (payload && typeof payload === "object") {
    payloadJson = payload;
  } else if (typeof payloadText === "string" && payloadText.length) {
    try {
      payloadJson = JSON.parse(payloadText);
    } catch {
      payloadJson = null;
    }
  }
  if (payloadJson === undefined) payloadJson = null;

  // Phase 25: Exact-dupe idempotency — if exact (kind,payload) already exists, do nothing.
  try {
    const dup = await pool.query(
      "select 1 as ok from task_events where kind=$1::text and payload=$2::text limit 1",
      [k, payloadText]
    );
    if (dup && (dup.rowCount || dup.rows?.length)) return;
  } catch (_) {
    // If dedupe query fails, continue (do not block writes).
  }

  // Phase 25: Terminal lockout — reject non-terminal lifecycle events after terminal.
  if (__PHASE25_LIFECYCLE_KINDS.has(k) && taskId && !__PHASE25_TERMINAL_KINDS.has(k)) {
    try {
      const like = `%\\\"task_id\\\":\\\"${String(taskId)}\\\"%`;
      const term = await pool.query(
        "select kind from task_events where kind = any($1::text[]) and payload like $2 order by id desc limit 1",
        [Array.from(__PHASE25_TERMINAL_KINDS), like]
      );
      const tk = term?.rows?.[0]?.kind;
      if (tk) {
        throw new Error(`phase25: reject post-terminal event kind=${k} after=${tk}`);
      }
    } catch (e) {
      if (String(e?.message || "").startsWith("phase25:")) throw e;
    }
  }

  await pool.query(
    "insert into task_events(kind, task_id, run_id, actor, ts, payload, payload_jsonb) values ($1::text, $2::text, $3::text, $4::text, $5::bigint, $6::text, $7::jsonb)",
    [k, (taskId == null ? null : String(taskId)), run_id, actor, ts, payloadText, payloadJson]
  );
}


