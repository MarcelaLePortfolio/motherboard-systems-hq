import { pool } from "../server/db_pool.mjs";
import { dbDelegateTask, dbCompleteTask } from "../server/tasks-mutations.mjs";

const created = await dbDelegateTask(pool, {
  title: "phase19 real mutation create",
  agent: "dev",
  source: "smoke",
  actor: "smoke",
});
console.log("created:", created?.id);

const completed = await dbCompleteTask(pool, {
  taskId: created?.id,
  status: "done",
  source: "smoke",
  actor: "smoke",
});
console.log("completed:", completed?.id, completed?.status);

await pool.end?.();
