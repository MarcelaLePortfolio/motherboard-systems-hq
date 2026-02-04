import { Pool } from "pg";

/**
 * Phase 36.1 — read-only run-centric observability
 * GET /api/runs/:run_id
 */
function getPool() {
  const url = process.env.POSTGRES_URL || process.env.DATABASE_URL;
  if (!url) throw new Error("Missing POSTGRES_URL (or DATABASE_URL)");

  // Prefer the app-wide pool if present; else create a small dedicated pool.
  if (globalThis.__DB_POOL) return globalThis.__DB_POOL;

  if (!globalThis.__PHASE36_RUNVIEW_POOL) {
    globalThis.__PHASE36_RUNVIEW_POOL = new Pool({
      connectionString: url,
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
