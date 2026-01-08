/**
 * Legacy task_events schema in your docker DB:
 *   task_events(id bigint, kind text, payload text, created_at text)
 *
 * So we store payload as JSON string into the text column.
 */
export async function appendTaskEvent(pool, kind, payload) {
  if (!pool) throw new Error("appendTaskEvent requires pool");
  const p = payload ?? {};
  await pool.query(
    `insert into task_events (kind, payload) values ($1::text, $2::text)`,
    [String(kind), JSON.stringify(p)]
  );
}
