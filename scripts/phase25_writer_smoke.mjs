import pg from "pg";
import { appendTaskEvent } from "../server/task-events.mjs";

const { Pool } = pg;

const pool = new Pool({
  connectionString: process.env.POSTGRES_URL || process.env.DATABASE_URL,
});

function ms() { return Date.now(); }

async function main() {
  const task_id = "phase25-writer-1";
  const baseObj = { task_id, run_id: "r1", ts: ms(), msg: "hello" };

  console.log("1) insert task.created via writer");
  await appendTaskEvent(pool, "task.created", baseObj);

  console.log("2) insert exact duplicate via writer (should NOOP)");
  await appendTaskEvent(pool, "task.created", baseObj);

  console.log("3) insert terminal task.completed via writer");
  await appendTaskEvent(pool, "task.completed", { ...baseObj, ts: ms(), msg: "done" });

  console.log("4) attempt post-terminal task.progress via writer (should throw phase25: reject...)");
  try {
    await appendTaskEvent(pool, "task.progress", { ...baseObj, ts: ms(), msg: "should-reject" });
    console.log("ERROR: expected reject did not happen");
    process.exitCode = 2;
  } catch (e) {
    console.log("OK_REJECT:", String(e?.message || e));
  }

  const r = await pool.query(
    "select kind, id, payload from task_events where payload like $1 order by id desc limit 20",
    [`%${task_id}%`]
  );
  console.log("5) recent rows:");
  for (const row of r.rows) console.log(row.id, row.kind, row.payload);

  await pool.end();
}

main().catch((e) => {
  console.error("SMOKE_FAIL");
  console.error(e?.stack || e);
  process.exitCode = 1;
});
