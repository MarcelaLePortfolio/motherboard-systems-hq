/**
 * appendTaskEvent(pool, kind, payload)
 *
 * Supports BOTH task_events schemas:
 *  A) "wide" schema: (task_id, type, ts, run_id, actor, meta)
 *  B) "legacy" schema: (kind, payload)
 *
 * We try A first, and if columns don't exist, we fall back to B.
 */
export async function appendTaskEvent(pool, kind, payload) {
  if (!pool) throw new Error("appendTaskEvent requires pool");

  const p = payload ?? {};
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

  // Try "wide" schema first
  try {
    await pool.query(
      `insert into task_events (task_id, type, ts, run_id, actor, meta)
       values ($1::int, $2::text, $3::bigint, $4::text, $5::text, $6::jsonb)`,
      [taskId, kind, ts, runId, actor, meta]
    );
    return;
  } catch (e) {
    const msg = e?.message || String(e);
    // Fall back ONLY for missing-column style errors
    if (!/column .* does not exist/i.test(msg)) throw e;
  }

  // Fallback: legacy schema (kind, payload)
  await pool.query(
    `insert into task_events (kind, payload) values ($1::text, $2::jsonb)`,
    [kind, p]
  );
}
