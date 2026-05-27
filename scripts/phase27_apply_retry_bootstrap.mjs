import pg from "pg";
import { bootstrapTasksRetrySemantics } from "../server/db_bootstrap_tasks_retry_semantics.mjs";

const { Pool } = pg;

function normalizeDbUrl(raw) {
  try {
    if (!raw) return "";
    if (!/^postgres(ql)?:\/\//i.test(raw)) return raw;
    const u = new URL(raw);
    const hasUser = (u.username || "") !== "";
    const hasPw = (u.password || "") !== "";
    if (hasUser && !hasPw) u.password = String(process.env.PGPASSWORD || "postgres");
    return u.toString();
  } catch {
    return raw;
  }
}

const DB_URL_RAW = process.env.POSTGRES_URL || process.env.DATABASE_URL || "";
const DB_URL = normalizeDbUrl(DB_URL_RAW);

const pool = DB_URL
  ? new Pool({ connectionString: DB_URL })
  : new Pool({
      host: process.env.PGHOST || "127.0.0.1",
      port: Number(process.env.PGPORT || 5432),
      user: process.env.PGUSER || "postgres",
      password: process.env.PGPASSWORD || "postgres",
      database: process.env.PGDATABASE || "postgres",
    });

await bootstrapTasksRetrySemantics(pool);
await pool.end();

console.log("ok: phase27 retry semantics bootstrap applied");
