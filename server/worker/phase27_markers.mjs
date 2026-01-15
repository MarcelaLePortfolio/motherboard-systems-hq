import fs from "node:fs";
import path from "node:path";
import { Pool } from "pg";

function mustEnv(name) {
  const v = process.env[name];
  return (v && String(v).trim()) ? String(v).trim() : null;
}

export function getPool() {
  if (globalThis.__DB_POOL) return globalThis.__DB_POOL;

  const url =
    mustEnv("POSTGRES_URL") ||
    mustEnv("DATABASE_URL") ||
    mustEnv("PGURL");

  if (!url) throw new Error("worker: missing POSTGRES_URL/DATABASE_URL/PGURL");

  const pool = new Pool({ connectionString: url });
  globalThis.__DB_POOL = pool;
  return pool;
}

function readSql(sqlPath) {
  const abs = path.isAbsolute(sqlPath) ? sqlPath : path.join(process.cwd(), sqlPath);
  return fs.readFileSync(abs, "utf8");
}

export async function markSuccess({ pool, sqlPath, task_id, run_id }) {
  const sql = readSql(sqlPath);
  return pool.query(sql, [task_id, run_id]);
}

export async function markFailure({
  pool,
  sqlPath,
  task_id,
  run_id,
  error = null,
  backoff_ms = null,
}) {
  const sql = readSql(sqlPath);
  const errStr =
    error == null ? null :
    (typeof error === "string" ? error : JSON.stringify(error));

  // Convention: $1 task_id, $2 run_id, $3 backoff_ms, $4 error
  return pool.query(sql, [task_id, run_id, backoff_ms, errStr]);
}
