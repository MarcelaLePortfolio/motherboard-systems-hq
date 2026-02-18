import { readFileSync } from "node:fs";
import { join } from "node:path";

export function registerPhase40_6ShadowAuditTaskEvents(app, { db }) {
  app.get("/api/shadow/audit/task-events", async (_req, res) => {
    const sqlPath = join(process.cwd(), "server", "sql", "phase40_6_shadow_audit_task_events.sql");
    const sqlText = readFileSync(sqlPath, "utf8");

    const startedAt = Date.now();
    const excludePrefix = String((_req.query && _req.query.exclude_prefix) || "");
    try {
      const r = await db.query(sqlText);
      const rows = Array.isArray(r) ? r : (r && r.rows) ? r.rows : [];
      const filtered = excludePrefix ? (rows || []).filter(r => !(String(r.task_id || "").startsWith(excludePrefix))) : (rows || []);
      const tookMs = Date.now() - startedAt;

      res.json({
        ok: true,
        scope: "phase40.6.shadow-audit.task-events",
        took_ms: tookMs,
        filtered
      });
    } catch (err) {
      const tookMs = Date.now() - startedAt;
      res.status(500).json({
        ok: false,
        scope: "phase40.6.shadow-audit.task-events",
        took_ms: tookMs,
        error: {
          name: err?.name || "Error",
          message: err?.message || String(err)
        }
      });
    }
  });
}
