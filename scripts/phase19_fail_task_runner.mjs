import pg from "pg";
import { dbDelegateTask, dbCompleteTask } from "../server/tasks-mutations.mjs";

const url =
  process.env.DATABASE_URL ||
  process.env.POSTGRES_URL ||
  process.env.POSTGRES_URI ||
  process.env.POSTGRES_CONNECTION_STRING;

if (!url) {
  console.error("Missing DATABASE_URL/POSTGRES_URL");
  process.exit(2);
}

const pool = new pg.Pool({ connectionString: url });

(async () => {
  try {
    const created = await dbDelegateTask(pool, {
      title: "phase19 fail runner",
      agent: "cade",
      notes: "runner smoke",
      source: "runner",
      trace_id: `phase19_fail_${Date.now()}`,
      meta: { ok: true, step: "fail_task_runner", ts: Date.now() },
    });

    const failed = await dbCompleteTask(pool, {
      id: created.id,
      status: "failed",
      error: "phase19 simulated failure",
      source: "runner",
      meta: { ok: false, step: "fail_task_runner", ts: Date.now() },
    });

    console.log(JSON.stringify({ ok: true, created, failed }, null, 2));
  } catch (e) {
    console.error("FAIL_RUNNER_FAILED:", e?.stack || e);
    process.exit(2);
  } finally {
    await pool.end();
  }
})();
