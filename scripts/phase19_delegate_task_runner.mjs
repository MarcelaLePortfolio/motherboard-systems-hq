import pg from "pg";
import { dbDelegateTask } from "../server/tasks-mutations.mjs";

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

const body = {
  title: "phase19 delegate runner",
  agent: "cade",
  notes: "runner smoke",
  source: "runner",
  trace_id: `phase19_${Date.now()}`,
  meta: { ok: true, step: "delegate_task_runner", ts: Date.now() },
};

(async () => {
  try {
    const row = await dbDelegateTask(pool, body);
    console.log(JSON.stringify({ ok: true, task: row }, null, 2));
  } catch (e) {
    console.error("RUNNER_FAILED:", e?.stack || e);
    process.exit(2);
  } finally {
    await pool.end();
  }
})();
