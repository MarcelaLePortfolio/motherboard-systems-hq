# Phase 626 API Tasks List Zone

## server/routes/api-tasks-postgres.mjs lines 38-85
// GET /api/tasks?limit=25  -> recent tasks for dashboard widget
apiTasksRouter.get("/", async (req, res) => {
  console.log("[phase57c-router] /api/tasks probe", {
    originalUrl: req.originalUrl,
    baseUrl: req.baseUrl,
    path: req.path,
    referer: req.get("referer") || null,
    userAgent: req.get("user-agent") || null,
    accept: req.get("accept") || null,
  });

  try {
    const pool = _getPoolOrFail(res);
    if (!pool) return;

    const limit = Math.max(1, Math.min(200, Number(req.query?.limit ?? 25) || 25));
    const r = await pool.query(
      `
      SELECT
        t.id,
        t.task_id,
        t.title,
        t.status,
        t.claimed_by,
        t.updated_at,
        completed.payload->>'outcome_preview' AS outcome_preview,
        completed.payload->>'explanation_preview' AS explanation_preview
      FROM tasks t
      LEFT JOIN LATERAL (
        SELECT te.payload
        FROM task_events te
        WHERE te.task_id = t.task_id
          AND te.kind = 'task.completed'
        ORDER BY te.id DESC
        LIMIT 1
      ) completed ON true
      ORDER BY t.updated_at DESC NULLS LAST, t.id DESC
      LIMIT $1
      `,
      [limit]
    );

    res.status(200).json({ ok: true, tasks: r.rows || [] });
  } catch (e) {
    console.error("[phase25] /api/tasks list error", e);
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});
