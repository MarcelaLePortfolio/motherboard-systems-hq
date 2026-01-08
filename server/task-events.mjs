import pg from "pg";

function _getDbUrl() {
  // Prefer the same env var Phase 19 runners used.
  // Keep compatibility if other envs exist.
  return (
    process.env.POSTGRES_URL ||
    process.env.DATABASE_URL ||
    process.env.PG_URL ||
    ""
  );
}

const url = _getDbUrl();
if (!url) {
  console.warn("[task-events] no POSTGRES_URL/DATABASE_URL set; task-events will fail until configured");
}

export const pool = new pg.Pool({ connectionString: url });

export async function appendTaskEvent(type, payload) {
  const taskId = payload?.task_id ?? payload?.taskId ?? null;
  const ts = payload?.ts ?? Date.now();
  const runId = payload?.run_id ?? payload?.runId ?? null;
  const actor = payload?.actor ?? null;

  // Store the full payload as meta, but remove duplicated keys where helpful
  const meta = { ...payload };
  delete meta.task_id;
  delete meta.taskId;
  delete meta.ts;
  delete meta.run_id;
  delete meta.runId;
  delete meta.actor;

  await pool.query(
    `insert into task_events (task_id, type, ts, run_id, actor, meta)
     values ($1::int, $2::text, $3::bigint, $4::text, $5::text, $6::jsonb)`,
    [taskId, type, ts, runId, actor, meta]
  );
}
