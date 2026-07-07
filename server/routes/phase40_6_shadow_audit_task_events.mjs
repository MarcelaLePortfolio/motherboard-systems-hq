import { readFileSync } from "node:fs";
import { join } from "node:path";

export function registerPhase40_6ShadowAuditTaskEvents(app, { db }) {
  app.get("/api/shadow/audit/task-events", async (req, res) => {
    const sqlPath = join(process.cwd(), "server", "sql", "phase40_6_shadow_audit_task_events.sql");
    const sqlText = readFileSync(sqlPath, "utf8");

    const startedAt = Date.now();
    const excludePrefix = String((req.query && req.query.exclude_prefix) || "");

    try {
      const r = await db.query(sqlText);

      // Support both shapes:
      // - Array (some wrappers)
      // - { rows: [...] } (pg Pool-style)
      const rows = Array.isArray(r) ? r : (r && r.rows) ? r.rows : [];

      const filtered = excludePrefix
        ? rows.filter(x => !String(x?.task_id || "").startsWith(excludePrefix))
        : rows;

      const tookMs = Date.now() - startedAt;

      const debug = {
        result_shape: Array.isArray(r)
          ? "array"
          : (r && typeof r === "object" && ("rows" in r))
            ? "object_rows"
            : typeof r,
        returned: rows.length,
        filtered: filtered.length,
        excludePrefix: excludePrefix || null
      };

      res.json({
        ok: true,
        scope: "phase40.6.shadow-audit.task-events",
        took_ms: tookMs,
        rows: filtered,
        debug
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
        },
        debug: {
          excludePrefix: excludePrefix || null
        }
      });
    }
  });
}
