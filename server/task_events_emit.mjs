/**
 * Centralized helper to emit task lifecycle events into task_events table.
 *
 * Canonical writer: appendTaskEvent(pool, kind, payload)
 * Pool source: prefer explicit pool, else globalThis.__DB_POOL (same source used by SSE routes).
 */
import { appendTaskEvent } from "./task-events.mjs";

export async function emitTaskEvent({
  pool = null,
  kind,
  task_id,
  run_id = null,
  actor = "system",
  payload = {},
}) {
  const p = pool ?? globalThis.__DB_POOL;
  if (!p) throw new Error("emitTaskEvent: DB pool not initialized (no pool arg, no globalThis.__DB_POOL)");

  const ts = Date.now();
  const data = {
    ts,
    task_id: (task_id ?? null),
    run_id: (run_id ?? null),
    actor,
    ...(payload ?? {}),
  };

  await appendTaskEvent(p, String(kind), data);
  return { ok: true, kind: String(kind), payload: data };
}
