/**
 * Phase 25 — Writer smoke (deterministic + collision-free)
 * Emits task.created/task.completed/task.failed using UNIQUE task_ids
 * so task lifecycle guards never reject due to prior terminal history.
 */
import pg from "pg";
import { emitTaskEvent } from "../server/task_events_emit.mjs";

const { Pool } = pg;

function resolveDatabaseUrl() {
  const envUrl =
    process.env.DATABASE_URL ||
    process.env.POSTGRES_URL ||
    process.env.PG_URL ||
    "";

  if (typeof envUrl === "string" && envUrl.trim()) return envUrl.trim();
  return "postgres://postgres:postgres@127.0.0.1:5432/postgres";
}

function mask(url) {
  return String(url).replace(/:(?:[^@]+)@/, ":***@");
}

async function main() {
  const databaseUrl = resolveDatabaseUrl();
  console.log("db:", mask(databaseUrl));

  const pool = new Pool({ connectionString: databaseUrl });

  const base = { run_id: "manual", actor: "dev" };
  const ts = Date.now();

  const tCreated = `phase25-writer-created-${ts}`;
  const tCompleted = `phase25-writer-comp  const tCompleted = `phase25-writer-comp  const tCompleted `;  const tCompleted = `phase25-writer-comp  const tCompleted = `phase2te  const tCompleted = `phase25-writer-comp  const tCompleted = `phase25ea  d,  const tCom

  conso  conso  conso  conso  conso  conso  conso  conso  conso  conslet  cons
  await emitTas  await emitTas  await emitTampl  await emitTd: tCompleted, ...base });

  console.log("3) insert task.failed via writer", { task_id: tFailed });
  await emitTaskEvent({
    pool,
    kind: "task.failed",
    task_id: tFailed,
    ...base,
    payload: { error: "phase25 writer smoke" },
           ait pool.end();
  console.log("SMOKE_OK");
}

main().catch((err) => {
  console.error("SMOKE_FAIL");
  console.error(err?.stack || err);
  process.exit(1);
});
