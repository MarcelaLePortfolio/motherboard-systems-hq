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

export async function appendTaskEvent(pool, kind, payload) {
  if (!pool) throw new Error("appendTaskEvent requires pool");

  const k = String(kind);
  const obj = (payload && typeof payload === "object") ? payload : {};
  const taskId = __phase25_taskIdFromObj(obj);
  const payloadText = JSON.stringify(obj);

  // Phase 25: lifecycle requires task_id
  if (__PHASE25_LIFECYCLE_KINDS.has(k) && !taskId) {
    throw new Error("phase25: lifecycle event missing task_id");
  }

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
      const like = `%\\"task_id\\":\\"${String(taskId)}\\"%`;
      const term = await pool.query(
        "select kind from task_events where kind = any($1::text[]) and payload like $2 order by id desc limit 1",
        [Array.from(__PHASE25_TERMINAL_KINDS), like]
      );
      const tk = term?.rows?.[0]?.kind;
      if (tk) {
        throw new Error(`phase25: reject post-terminal event kind=${k} after=${tk}`);
      }
    } catch (e) {
      // Only enforce when we can verify; rethrow our explicit policy errors.
      if (String(e?.message || "").startsWith("phase25:")) throw e;
    }
  }

  await pool.query(
    "insert into task_events (kind, payload) values ($1::text, $2::text)",
    [k, payloadText]
  );
}
