/**
 * Centralized helper to emit task lifecycle events into task_events table.
 * Canonical write path delegates to appendTaskEvent (Phase 21 verified with SSE reader).
 */
import { appendTaskEvent } from "./task-events.mjs";

export async function emitTaskEvent({
  kind,
  task_id,
  run_id = null,
  actor = "system",
  payload = {}
}) {
  const ts = Date.now();
  return appendTaskEvent(kind, {
    ts,
    task_id,
    run_id,
    actor,
    ...payload,
  });
}
