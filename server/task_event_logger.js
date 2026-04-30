async function logTaskEvent(db, {
  task_id,
  kind,
  actor = "system",
  payload = {},
  run_id = null
}) {
  try {
    await db.query(
      `
      INSERT INTO task_events (task_id, kind, actor, payload, run_id, created_at, ts)
      VALUES ($1, $2, $3, $4, $5, NOW(), EXTRACT(EPOCH FROM NOW())::bigint)
      `,
      [task_id, kind, actor, payload, run_id]
    );
  } catch (err) {
    console.error("[task_event_logger] failed:", err);
  }
}

module.exports = { logTaskEvent };
