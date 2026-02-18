import { readFileSync } from "node:fs";
import { join } from "node:path";

export function registerPhase40_6ShadowAuditTaskEvents(app, { db }) {
  app.get("/api/shadow/audit/task-events", async (_req, res) => {
    const sqlPath = join(process.cwd(), "server", "sql", "phase40_6_shadow_audit_task_events.sql");
    const sqlText = readFileSync(sqlPath, "utf8");

    const startedAt = Date.now();
    const { rows } = await db.query(sqlText);
    const tookMs = Date.now() - startedAt;

    res.json({
      ok: true,
      scope: "phase40.6.shadow-audit.task-events",
      took_ms: tookMs,
      rows
    });
  });
}
