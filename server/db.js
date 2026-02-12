import { Pool } from "pg";
const POSTGRES_URL = process.env.POSTGRES_URL;
if (!POSTGRES_URL) {
  throw new Error("POSTGRES_URL is required (server/db.js).");
}

if (!globalThis.__MBHQ_POOL) {
  globalThis.__MBHQ_POOL = new Pool({ connectionString: POSTGRES_URL });
}

export const pool = globalThis.__MBHQ_POOL;
