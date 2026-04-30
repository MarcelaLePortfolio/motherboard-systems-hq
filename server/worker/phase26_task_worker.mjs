import { createRequire } from "module";
const require = createRequire(import.meta.url);
require("../worker_retry_enforcer.js");
const { Pool } = require("pg");
import fs from "fs";
import path from "path";
import crypto from "crypto";

const POSTGRES_URL =
  process.env.POSTGRES_URL ||
  process.env.DATABASE_URL ||
  "postgresql://postgres:postgres@postgres:5432/postgres";

const WORKER_DIR = path.resolve("/app/server/worker");
const OWNER = `worker-${crypto.randomUUID()}`;
const CLAIM_INTERVAL_MS = 5000;

function resolveSqlContracts() {
  let files = [];
  try {
    files = fs.readdirSync(WORKER_DIR);
  } catch (e) {
    throw new Error(`Worker directory not found: ${WORKER_DIR}`);
  }

  const phase32 = files.filter(f => f.startsWith("phase32_") && f.endsWith(".sql"));
  const phase27 = files.filter(f => f.startsWith("phase27_") && f.endsWith(".sql"));

  if (phase32.length > 0) {
    return {
      phase: "32",
      root: WORKER_DIR,
      files: phase32
    };
  }

  if (phase27.length > 0) {
    return {
      phase: "27",
      root: WORKER_DIR,
      files: phase27
    };
  }

  throw new Error("No SQL contracts found (expected phase32_* or phase27_* in /app/server/worker)");
}

function readSql(name) {
  return fs.readFileSync(path.join(WORKER_DIR, name), "utf8");
}

const SQL = resolveSqlContracts();
const CLAIM_SQL = readSql(`phase${SQL.phase}_claim_one.sql`);

console.log("[worker] resolved sql contracts:", {
  phase: SQL.phase,
  count: SQL.files.length
});

for (const f of SQL.files) {
  console.log("[worker] contract:", f);
}

async function claimOnce(pool) {
  const runId = `run_${crypto.randomUUID()}`;
  const result = await pool.query(CLAIM_SQL, [runId, OWNER]);
  const task = result.rows?.[0];

  if (!task) {
    return null;
  }

  console.log("[worker] claimed task", {
    id: task.id,
    task_id: task.task_id,
    status: task.status,
    run_id: task.run_id,
    claimed_by: task.claimed_by
  });

  return task;
}

async function main() {
  console.log("[worker] started with POSTGRES_URL:", POSTGRES_URL);
  console.log("[worker] running in phase:", SQL.phase);
  console.log("[worker] owner:", OWNER);

  const pool = new Pool({ connectionString: POSTGRES_URL });

  await pool.query("select 1");

  setInterval(() => {
    console.log("[worker] heartbeat");
  }, 30000);

  setInterval(async () => {
    try {
      await claimOnce(pool);
    } catch (err) {
      console.error("[worker] claim loop error:", err?.message || err);
    }
  }, CLAIM_INTERVAL_MS);
}

main().catch(err => {
  console.error("[worker] fatal error:", err);
  process.exit(1);
});
