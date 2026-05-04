import express from "express";

const router = express.Router();

function extractGuidanceFromTaskRow(row) {
  const payload = row?.payload && typeof row.payload === "object" ? row.payload : {};
  const outcome = payload.outcome_preview || payload.outcome || row?.outcome_preview || "";
  const explanation = payload.explanation_preview || payload.explanation || row?.explanation_preview || "";
  const communicationResult = payload.communicationResult || payload.communication_result || null;

  if (!outcome && !explanation && !communicationResult) return null;

  return {
    task_id: row.task_id,
    kind: row.kind || "task.completed",
    outcome_preview: outcome || null,
    explanation_preview: explanation || null,
    communicationResult,
    created_at: row.created_at || null,
  };
}

async function loadLatestGuidance(pool) {
  const result = await pool.query(`
    SELECT task_id, kind, payload, created_at
    FROM task_events
    WHERE kind = 'task.completed'
    ORDER BY id DESC
    LIMIT 10
  `);

  const guidance = result.rows
    .map(extractGuidanceFromTaskRow)
    .filter(Boolean);

  return {
    ok: true,
    guidance_available: guidance.length > 0,
    guidance,
  };
}

export default function operatorGuidanceRouter({ pool }) {
  router.get("/api/guidance", async (_req, res) => {
    try {
      const data = await loadLatestGuidance(pool);
      res.json(data);
    } catch (error) {
      res.status(500).json({
        ok: false,
        guidance_available: false,
        error: error?.message || String(error),
      });
    }
  });

  router.get("/events/operator-guidance", async (req, res) => {
    res.writeHead(200, {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache, no-transform",
      Connection: "keep-alive",
      "X-Accel-Buffering": "no",
    });

    const send = (event, data) => {
      res.write(`event: ${event}\n`);
      res.write(`data: ${JSON.stringify(data)}\n\n`);
    };

    let closed = false;
    req.on("close", () => {
      closed = true;
    });

    send("hello", {
      kind: "operator-guidance",
      ts: Date.now(),
    });

    const tick = async () => {
      if (closed) return;
      try {
        const data = await loadLatestGuidance(pool);
        send("operator-guidance", {
          ...data,
          ts: Date.now(),
        });
      } catch (error) {
        send("operator-guidance", {
          ok: false,
          guidance_available: false,
          error: error?.message || String(error),
          ts: Date.now(),
        });
      }
    };

    await tick();
    const interval = setInterval(tick, 5000);

    req.on("close", () => clearInterval(interval));
  });

  return router;
}
