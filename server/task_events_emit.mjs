/**
 * Centralized helper to emit task lifecycle events into task_events table.
 * Used by create/update/complete/fail paths.
 */
import { pool } from './db_pool.mjs';

export async function emitTaskEvent({
  kind,
  task_id,
  run_id = null,
  actor = 'system',
  payload = {}
}) {
  const ts = Date.now();
  const data = {
    ts,
    task_id,
    run_id,
    actor,
    ...payload
  };

  const sql = `
    insert into task_events(kind, payload)
    values ($1, $2::jsonb)
  `;

  await pool.query(sql, [kind, JSON.stringify(data)]);
}
