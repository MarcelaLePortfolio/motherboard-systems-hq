import express from "express";
import { generateGuidance } from "../lib/guidance-engine.js";
import { applyGuidancePriority } from "../lib/guidance-priority.js";

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
      updated_at,
      attempts,
      max_attempts,
      title,
      kind
    FROM tasks
    ORDER BY updated_at DESC
    LIMIT 25
  `);

  const tasks = result.rows || [];
  const failures = tasks.filter((task) => task.status === "failed" || task.status === "error");
  const retries = tasks.filter((task) => Number(task.attempts || 0) > 0);

  const subsystems = tasks.map((task) => ({
    id: task.task_id,
    name: task.title || task.kind || task.task_id,
    status: task.status,
    severity:
      task.status === "failed" || task.status === "error"
        ? "critical"
        : task.status === "queued"
          ? "warning"
          : "info",
    updated_at: task.updated_at,
    attempts: task.attempts,
    max_attempts: task.max_attempts,
  }));

  const engineResult = generateGuidance(subsystems);

  let guidance = Array.isArray(engineResult?.guidance)
    ? engineResult.guidance
    : Array.isArray(engineResult?.items)
      ? engineResult.items
      : Array.isArray(engineResult)
        ? engineResult
        : [];

  guidance = applyGuidancePriority(guidance);

  return {
    ok: true,
    guidance_available: guidance.length > 0,
    guidance,
    meta: {
      source: "guidance-engine",
      generated_at: new Date().toISOString(),
      task_count: tasks.length,
      failure_count: failures.length,
      retry_count: retries.length,
      subsystem_count: subsystems.length,
      ...(engineResult?.meta || {}),
    },
  };
}


export default function operatorGuidanceRouter({ pool }) {
  router.get("/api/guidance", async (_req, res) => {
    try {
      const payload = await buildGuidance(pool);
      recordGuidanceHistory(payload);
      res.json(payload);
    } catch (error) {
      console.error("[phase663-guidance-error]", error?.message || error);

      const payload = {
        ok: false,
        guidance_available: false,
        guidance: [],
        error: "guidance_unavailable",
        detail: error?.message || "unknown_error",
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
        console.error("[phase663-guidance-sse-error]", error?.message || error);

        const payload = {
          ok: false,
          guidance_available: false,
          guidance: [],
          error: "guidance_unavailable",
          detail: error?.message || "unknown_error",
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
