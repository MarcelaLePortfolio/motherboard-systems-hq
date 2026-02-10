import { Pool } from "pg";

/**
 * Phase 36.2 — read-only run-centric observability
 * GET /api/runs/:run_id
 *
 * Contract:
 * - Read-only
 * - Backed strictly by SQL view: run_view
 * - No writes, no derived state
 */
function getPool() {
  // Prefer the app-wide pool if present; this matches the server’s canonical DB config.
  if (globalThis.__DB_POOL) return globalThis.__DB_POOL;

  const url = process.env.POSTGRES_URL || process.env.DATABASE_URL;

  // If URL is not provided, fall back to PG* env vars (matches server.mjs behavior).
  // NOTE: In containers, PGHOST should be "postgres" (service DNS), not 127.0.0.1.
  const cfg = url
    ? { connectionString: url }
    : {
        host: process.env.PGHOST || "127.0.0.1",
        port: Number(process.env.PGPORT || 5432),
        user: process.env.PGUSER || "postgres",
        password: process.env.PGPASSWORD || "postgres",
        database: process.env.PGDATABASE || "postgres",
      };

  if (!globalThis.__PHASE36_RUNVIEW_POOL) {
    globalThis.__PHASE36_RUNVIEW_POOL = new Pool({
      ...cfg,
      max: 5,
      idleTimeoutMillis: 30_000,
    });
  }
  return globalThis.__PHASE36_RUNVIEW_POOL;
}

export function registerPhase36RunView(app) {
  app.get("/api/runs/:run_id", async (req, res) => {
    const run_id = String(req.params.run_id || "").trim();
    if (!run_id) return res.status(400).json({ error: "run_id required" });

    try {
      const pool = getPool();
      const q = "SELECT * FROM run_view WHERE run_id = $1 LIMIT 1";
      const r = await pool.query(q, [run_id]);

      if (!r.rows?.length) return res.status(404).json({ error: "not_found", run_id });
      return res.status(200).json(r.rows[0]);
    } catch (e) {
      return res.status(500).json({ error: "query_failed", detail: String(e?.message || e) });
    }
  });
}
