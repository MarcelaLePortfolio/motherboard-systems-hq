import { Pool } from "pg";
import { pool } from "../db.mjs";

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
  // Phase 36.4 — Run list observability (read-only, deterministic; DB is source of truth)
  // GET /api/runs?limit=200&task_status=created&task_status=running&is_terminal=true&since_ts=1770000000000
  app.get("/api/runs", async (req, res) => {
    try {
      const pool = getPool();

      // limit: clamp 1..200, default 50
      const rawLimit = Array.isArray(req.query.limit) ? req.query.limit[0] : req.query.limit;
      const limit = Math.max(1, Math.min(200, Number(rawLimit ?? 50) || 50));

      // task_status[]: allow repeated query keys (?task_status=a&task_status=b)
      const rawStatuses = req.query.task_status;
      const statuses = (Array.isArray(rawStatuses) ? rawStatuses : (rawStatuses ? [rawStatuses] : []))
        .map((s) => String(s).trim())
        .filter(Boolean);

      // is_terminal: optional boolean
      const rawIsTerminal = Array.isArray(req.query.is_terminal) ? req.query.is_terminal[0] : req.query.is_terminal;
      const is_terminal =
        rawIsTerminal === undefined ? undefined :
        (String(rawIsTerminal).toLowerCase() === "true" ? true :
         String(rawIsTerminal).toLowerCase() === "false" ? false : undefined);

      // since_ts: optional integer (ms epoch)
      const rawSince = Array.isArray(req.query.since_ts) ? req.query.since_ts[0] : req.query.since_ts;
      const since_ts = rawSince === undefined ? undefined : (Number(rawSince) || undefined);

      const where = [];
      const params = [];
      let p = 1;

      if (statuses.length > 0) {
        where.push(`task_status = ANY($${p}::text[])`);
        params.push(statuses);
        p++;
      }

      if (is_terminal !== undefined) {
        where.push(`is_terminal = $${p}::boolean`);
        params.push(is_terminal);
        p++;
      }

      if (since_ts !== undefined) {
        where.push(`last_event_ts >= $${p}::bigint`);
        params.push(since_ts);
        p++;
      }

      const whereSql = where.length ? `WHERE ${where.join(" AND ")}` : "";

      // Deterministic ordering (no UI inference): newest activity first; stable tie-breaks
      const sql = `
        
    SELECT
          run_id,
          task_id,
          task_status,
          is_terminal,
          last_event_id,
          last_event_ts,
          last_event_kind,
          actor,
          lease_expires_at,
          lease_fresh,
          lease_ttl_ms,
          last_heartbeat_ts,
          heartbeat_age_ms,
          terminal_event_kind,
          terminal_event_ts,
          terminal_event_id
  
        FROM run_view
        ${whereSql}
        ORDER BY
          last_event_ts DESC NULLS LAST,
          last_event_id DESC NULLS LAST,
          run_id DESC
        LIMIT $${p}::int
      `;

      params.push(limit);

      const { rows } = await pool.query(sql, params);
      res.status(200).json({ ok: true, count: rows.length, rows });
    } catch (err) {
      res.status(500).json({ ok: false, error: String(err?.message || err) });
    }
  });


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

const DEFAULT_LIMIT = 50;
const MAX_LIMIT = 200;

export async function getRunsList(req, res) {
  const rawLimit = Number((req && req.query && req.query.limit) ?? DEFAULT_LIMIT);
  const limit = Number.isFinite(rawLimit) && rawLimit > 0
    ? Math.min(rawLimit, MAX_LIMIT)
    : DEFAULT_LIMIT;

  const sql = `
    SELECT *
    FROM run_view
    ORDER BY created_at DESC, run_id DESC
    LIMIT $1
  `;

  try {
    const { rows } = await pool.query(sql, [limit]);
    return res.status(200).json(rows);
  } catch (err) {
    console.error("GET /api/runs failed", err);
    return res.status(500).json({ error: "internal_error" });
  }
}
