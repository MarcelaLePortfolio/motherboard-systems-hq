
import pg from "pg";

import { dbDelegateTask, dbCompleteTask } from "./server/tasks-mutations.mjs";

const { Pool } = pg;

const pool = new Pool({

  connectionString:

    process.env.POSTGRES_URL ||

    process.env.DATABASE_URL ||

    "postgres://postgres:postgres@localhost:5432/postgres",

});

const run_id = `direct-smoke-${Date.now()}`;

try {

  console.log("===== DIRECT dbDelegateTask =====");

  const delegated = await dbDelegateTask(pool, {

    title: "Direct dbCompleteTask run_id smoke",

    agent: "cade",

    source: "direct_db_smoke",

    run_id,

    notes: "Direct smoke for dbCompleteTask run_id propagation",

  });

  console.log(JSON.stringify({ delegated, run_id }, null, 2));

  console.log("===== DIRECT dbCompleteTask =====");

  const completed = await dbCompleteTask(pool, {

    task_id: delegated.task_id,

    run_id,

    kind: "task.completed",

    source: "direct_db_smoke",

    notes: "Completed direct smoke",

  });

  console.log(JSON.stringify({ completed, run_id }, null, 2));

  console.log("===== DIRECT SMOKE PASSED =====");

} catch (error) {

  console.error("===== DIRECT SMOKE FAILED =====");

  console.error(error);

  process.exitCode = 1;

} finally {

  await pool.end();

}

