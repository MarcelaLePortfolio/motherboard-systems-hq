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

function __phase25_parsePayload(raw) {
  if (raw == null) return null;
  if (typeof raw === "string") {
    try { return JSON.parse(raw); } catch { return null; }
  }
  if (typeof raw === "object") return raw;
  return null;
}

function __phase25_taskIdFromPayload(payload) {
  return payload?.task_id ?? payload?.taskId ?? payload?.task?.id ?? null;
}

/**
 * Legacy task_events schema in your docker DB:
 *   task_events(id bigint, kind text, payload text, created_at text)
 *
 * So we store payload as JSON string into the text column.
 */
// SINGLE AUTHORITATIVE TASK EVENT WRITER — Phase 25 contract enforced.
export async function appendTaskEvent(pool, kind, payload) {
  if (!pool) throw new Error("appendTaskEvent requires pool");
  const p = payload ?? {};
  await pool.query(

    // Phase 25 guardrails (writer-side)

    const __p25_payloadObj = __phase25_parsePayload(payload);

    const __p25_taskId = __phase25_taskIdFromPayload(__p25_payloadObj);


    // Exact-dupe idempotency: if exact (kind,payload) already exists, do nothing.

    try {

      const dup = await db.query(

        "select 1 as ok from task_events where kind=$1::text and payload=$2::text limit 1",

        [String(kind), String(payload)]

      );

      if (dup && (dup.rowCount || dup.rows?.length)) return { ok: true, deduped: true };

    } catch (_) {

      // If dedupe query fails, continue (do not block writes).

    }


    // Lifecycle requires task_id for lifecycle kinds.

    if (__PHASE25_LIFECYCLE_KINDS.has(String(kind)) && !__p25_taskId) {

      throw new Error("phase25: lifecycle event missing task_id");

    }


    // Terminal lockout: reject lifecycle events after terminal.

    if (__PHASE25_LIFECYCLE_KINDS.has(String(kind)) && __p25_taskId) {

      try {

        const term = await db.query(

          "select kind from task_events where payload like $1 and kind = any($2::text[]) order by cursor desc nulls last, id desc limit 1",

          [\"%\\"task_id\\":\\"\" + String(__p25_taskId) + \"\\"%\", Array.from(__PHASE25_TERMINAL_KINDS)]

        );

        const tk = term?.rows?.[0]?.kind;

        if (tk && !__PHASE25_TERMINAL_KINDS.has(String(kind))) {

          throw new Error(`phase25: reject post-terminal event kind=${kind} after=${tk}`);

        }

      } catch (e) {

        // If query fails, do not block writes (only enforce when we can verify).

        if (String(e?.message || "").startsWith("phase25:")) throw e;

      }

    }`insert into task_events (kind, payload) values ($1::text, $2::text)`,
    [String(kind), JSON.stringify(p)]
  );
}
