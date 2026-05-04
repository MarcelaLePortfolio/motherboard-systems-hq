import express from "express";

const router = express.Router();
const MAX_GUIDANCE_HISTORY = 50;
const guidanceHistory = [];

function recordGuidanceHistory(snapshot) {
  if (!snapshot) return;

  guidanceHistory.unshift({
    timestamp: Date.now(),
    snapshot,
  });

  if (guidanceHistory.length > MAX_GUIDANCE_HISTORY) {
    guidanceHistory.length = MAX_GUIDANCE_HISTORY;
  }
}

async function buildGuidance(pool) {
  const result = await pool.query(`
    SELECT
      task_id,
      status,
      agent,
      title,
      updated_at,
      error_message
    FROM tasks
    ORDER BY updated_at DESC
    LIMIT 25
  `);

  const guidance = result.rows
    .map((row) => {
      if (row.status === "failed") {
        return {
          severity: "critical",
          task_id: row.task_id,
          title: row.title,
          message: "Task failed and may require operator review.",
          suggested_action: "Inspect task failure and retry only if the cause is understood.",
          updated_at: row.updated_at,
        };
      }

      if (row.status === "queued") {
        return {
          severity: "warning",
          task_id: row.task_id,
          title: row.title,
          message: "Task is queued and waiting for worker pickup.",
          suggested_action: "Confirm worker heartbeat if queue does not drain.",
          updated_at: row.updated_at,
        };
      }

      return null;
    })
    .filter(Boolean)
    .sort((a, b) => {
      const rank = { critical: 0, warning: 1, info: 2 };
      return (rank[a.severity] ?? 9) - (rank[b.severity] ?? 9);
    });

  return {
    ok: true,
    guidance_available: guidance.length > 0,
    guidance,
  };
}

export default function operatorGuidanceRouter({ pool }) {
  router.get("/api/guidance", async (_req, res) => {
    try {
      const payload = await buildGuidance(pool);
      recordGuidanceHistory(payload);
      res.json(payload);
    } catch (error) {
      const payload = {
        ok: false,
        guidance_available: false,
        guidance: [],
        error: "guidance_unavailable",
      };
      recordGuidanceHistory(payload);
      res.status(500).json(payload);
    }
  });

  router.get("/api/guidance-history", (_req, res) => {
    res.json({
      ok: true,
      history_available: guidanceHistory.length > 0,
      history: guidanceHistory,
    });
  });

  router.get("/events/operator-guidance", async (req, res) => {
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("Connection", "keep-alive");

    const send = (event, payload) => {
      res.write(`event: ${event}\n`);
      res.write(`data: ${JSON.stringify(payload)}\n\n`);
    };

    let closed = false;

    req.on("close", () => {
      closed = true;
    });

    const emit = async () => {
      if (closed) return;

      try {
        const payload = await buildGuidance(pool);
        recordGuidanceHistory(payload);
        send("operator-guidance", payload);
      } catch (error) {
        const payload = {
          ok: false,
          guidance_available: false,
          guidance: [],
          error: "guidance_unavailable",
        };
        recordGuidanceHistory(payload);
        send("operator-guidance", payload);
      }
    };

    await emit();
    const interval = setInterval(emit, 5000);

    req.on("close", () => {
      clearInterval(interval);
    });
  });

  return router;
}
