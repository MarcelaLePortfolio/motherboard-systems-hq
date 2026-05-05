import express from "express";
import { generateGuidance } from "../lib/guidance-engine.js";
import deriveCoherentGuidance from "../guidance/coherence-adapter.mjs";
import {
  appendGuidanceEvents,
  readRecentGuidanceEvents,
} from "../guidance/guidance-history-store.mjs";

const router = express.Router();
const MAX_GUIDANCE_HISTORY = 50;
const guidanceHistory = [];

function flattenGuidanceHistory(history) {
  return history.flatMap((entry) => {
    const snapshot = entry?.snapshot || {};
    const generatedAt =
      snapshot?.meta?.generated_at ||
      snapshot?.timestamp ||
      (entry?.timestamp ? new Date(entry.timestamp).toISOString() : new Date().toISOString());

    const guidance = Array.isArray(snapshot?.guidance) ? snapshot.guidance : [];

    return guidance.map((item) => ({
      timestamp: item.generated_at || generatedAt,
      task_id: item.task_id || item.source_task_id || "global",
      subsystem: item.subsystem || "guidance",
      signal_type: item.type || "generic",
      severity:
        typeof item.severity === "number"
          ? item.severity >= 3
            ? "critical"
            : item.severity === 2
              ? "warning"
              : "info"
          : item.severity || "info",
      message: item.message || item.suggested_action || "",
    }));
  });
}

function recordGuidanceHistory(snapshot) {
  if (!snapshot) return;

  const entry = {
    timestamp: Date.now(),
    snapshot,
  };

  guidanceHistory.unshift(entry);

  if (guidanceHistory.length > MAX_GUIDANCE_HISTORY) {
    guidanceHistory.length = MAX_GUIDANCE_HISTORY;
  }

  appendGuidanceEvents(flattenGuidanceHistory([entry]));
}

function mergeGuidanceEvents(memoryEvents = [], persistedEvents = []) {
  const seen = new Set();
  const merged = [];

  for (const event of [...persistedEvents, ...memoryEvents]) {
    const key = [
      event?.timestamp,
      event?.task_id,
      event?.subsystem,
      event?.signal_type,
      event?.message,
    ].join("::");

    if (!seen.has(key)) {
      seen.add(key);
      merged.push(event);
    }
  }

  return merged;
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

  const subsystems = [];

  if (failures.length > 0) {
    subsystems.push({
      name: "execution",
      status: "degraded",
      failure_count: failures.length,
    });
  }

  if (tasks.some((task) => task.status === "queued")) {
    subsystems.push({
      name: "task-queue",
      status: "queued",
      queued_count: tasks.filter((task) => task.status === "queued").length,
    });
  }

  if (retries.length > 0) {
    subsystems.push({
      name: "task-retries",
      status: "active",
      retry_count: retries.length,
    });
  }

  const engineResult = generateGuidance(subsystems);

  const rawGuidance = Array.isArray(engineResult?.guidance)
    ? engineResult.guidance
    : Array.isArray(engineResult?.items)
      ? engineResult.items
      : Array.isArray(engineResult)
        ? engineResult
        : [];

  const failedTaskIds = failures.map((task) => task.task_id).filter(Boolean);
  const retryTaskIds = retries.map((task) => task.task_id).filter(Boolean);
  const queuedTaskIds = tasks
    .filter((task) => task.status === "queued")
    .map((task) => task.task_id)
    .filter(Boolean);

  const guidance = rawGuidance.map((item) => {
    if (item.subsystem === "execution") {
      return {
        ...item,
        task_id: failedTaskIds[0] || null,
        related_task_ids: failedTaskIds,
        failure_count: failures.length,
      };
    }

    if (item.subsystem === "task-retries") {
      return {
        ...item,
        task_id: retryTaskIds[0] || null,
        source_task_id: failures[0]?.task_id || null,
        related_task_ids: retryTaskIds,
        retry_count: retries.length,
      };
    }

    if (item.subsystem === "task-queue") {
      return {
        ...item,
        task_id: queuedTaskIds[0] || null,
        related_task_ids: queuedTaskIds,
        queued_count: queuedTaskIds.length,
      };
    }

    return item;
  });

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

  router.get("/api/guidance/coherence-shadow", (_req, res) => {
    const memoryEvents = flattenGuidanceHistory(guidanceHistory);
    const persisted = readRecentGuidanceEvents(250);
    const persistedEvents = persisted.ok ? persisted.events : [];
    const raw = mergeGuidanceEvents(memoryEvents, persistedEvents);
    const coherent = deriveCoherentGuidance(raw);

    res.json({
      phase: "680",
      mode: "coherence-shadow",
      runtimeImpact: {
        execution: false,
        sse: false,
        ui: false,
        formatting: false,
      },
      source: persisted.ok && persistedEvents.length > 0 ? "merged" : "express-guidance-history",
      persistence: {
        enabled: persisted.ok,
        source: persisted.source,
        event_count: persistedEvents.length,
        error: persisted.error || null,
      },
      history_available: guidanceHistory.length > 0 || persistedEvents.length > 0,
      raw,
      coherent,
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
