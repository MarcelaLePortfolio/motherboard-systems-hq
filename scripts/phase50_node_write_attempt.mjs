import pg from "pg";
import { dbDelegateTask } from "../server/tasks-mutations.mjs";

const url = process.env.POSTGRES_URL || process.env.DATABASE_URL;
if (!url) {
  console.error("ERROR: set POSTGRES_URL (or DATABASE_URL) to run this smoke.");
  process.exit(2);
}

const pool = new pg.Pool({ connectionString: url });

try {
  const row = await dbDelegateTask(pool, {
    title: "phase50-node-smoke",
    agent: "cade",
    notes: "enforce-on should block",
    source: "smoke",
    trace_id: "phase50-node-smoke",
    actor: "smoke",
    meta: { phase: 50 },
  });
  console.error("UNEXPECTED: write succeeded", row);
  process.exit(3);
} catch (e) {
  console.log("OK: write blocked:", e?.code || e?.name || String(e));
} finally {
  await pool.end();
}
