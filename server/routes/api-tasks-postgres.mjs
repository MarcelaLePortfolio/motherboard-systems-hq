import express from "express";
console.log("[phase25] api-tasks-postgres loaded", new Date().toISOString(), "file=", import.meta.url);
import { emitTaskEvent } from "../task_events_emit.mjs";

export const apiTasksRouter = express.Router();

function _asJson(req) {
  const b = req.body;
  if (b == null) return {};
  if (typeof b === "object") return b;
  if (typeof b === "string") {
    try { return JSON.parse(b); } catch (_) { return { _raw: b }; }
  }
  return { _raw: b };
}

function _getPoolOrFail(res) {
  const pool = globalThis.__DB_POOL;
  console.log("[phase25] _getPoolOrFail", { has: !!pool, type: pool?.constructor?.name, keys: pool ? Object.keys(pool).slice(0,5) : [] });
  console.log("[phase25] _getPoolOrFail", { has: !!pool, type: pool?.constructor?.name, keys: pool ? Object.keys(pool).slice(0,5) : [] });
  if (!pool) {
    res.status(500).json({ ok: false, error: "db_pool_not_initialized" });
    return null;
  }
  return pool;
}

// Health (non-writing). Keep both endpoints for compatibility.
apiTasksRouter.get("/healthz", async (_req, res) => {
  res.status(200).json({ ok: true });
});
apiTasksRouter.get("/health", async (_req, res) => {
  res.status(200).json({ ok: true });
});

// POST /api/tasks/create  { task_id?, title?, agent?, run_id?, ... }
apiTasksRouter.post("/create", async (req, res) => {
  try {
    const pool = _getPoolOrFail(res); if (!pool) return;
      console.log("[phase25] /api/tasks/create pool snapshot", { hasLocal: !!pool, localType: pool?.constructor?.name, hasGlobal: !!globalThis.__DB_POOL, globalType: globalThis.__DB_POOL?.constructor?.name });
    const b = _asJson(req);
    const task_id = b.task_id ?? b.taskId ?? b.id ?? null;

    const evt = await emitTaskEvent({
      pool,
      pool,
      kind: "task.created",
      task_id,
      run_id: b.run_id ?? b.runId ?? null,
      actor: b.actor ?? "api",
      payload: {
        title: b.title ?? null,
        agent: b.agent ?? null,
        status: b.status ?? "delegated",
        source: b.source ?? "api",
        meta: b.meta ?? null,
      },
    });

    res.status(201).json({ ok: true, task_id, event: evt });
  } catch (e) {
    console.error("[phase25] /api/tasks error", e);

    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

// POST /api/tasks/complete  { task_id, status?, run_id?, ... }
apiTasksRouter.post("/complete", async (req, res) => {
  try {
    const pool = _getPoolOrFail(res); if (!pool) return;
    const b = _asJson(req);
    const task_id = b.task_id ?? b.taskId ?? b.id ?? null;
    if (!task_id) return res.status(400).json({ ok: false, error: "task_id_required" });

    const evt = await emitTaskEvent({
      pool,
      pool,
      kind: "task.completed",
      task_id,
      run_id: b.run_id ?? b.runId ?? null,
      actor: b.actor ?? "api",
      payload: {
        status: b.status ?? "complete",
        result: b.result ?? null,
        source: b.source ?? "api",
      },
    });

    res.status(200).json({ ok: true, task_id, event: evt });
  } catch (e) {
    console.error("[phase25] /api/tasks error", e);

    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

// POST /api/tasks/fail  { task_id, error?, status?, run_id?, ... }
apiTasksRouter.post("/fail", async (req, res) => {
  try {
    const pool = _getPoolOrFail(res); if (!pool) return;
    const b = _asJson(req);
    const task_id = b.task_id ?? b.taskId ?? b.id ?? null;
    if (!task_id) return res.status(400).json({ ok: false, error: "task_id_required" });

    const evt = await emitTaskEvent({
      pool,
      pool,
      kind: "task.failed",
      task_id,
      run_id: b.run_id ?? b.runId ?? null,
      actor: b.actor ?? "api",
      payload: {
        status: b.status ?? "failed",
        error: b.error ?? b.err ?? null,
        source: b.source ?? "api",
      },
    });

    res.status(200).json({ ok: true, task_id, event: evt });
  } catch (e) {
    console.error("[phase25] /api/tasks error", e);

    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

// POST /api/tasks/cancel  { task_id, run_id?, ... }
apiTasksRouter.post("/cancel", async (req, res) => {
  try {
    const pool = _getPoolOrFail(res); if (!pool) return;
    const b = _asJson(req);
    const task_id = b.task_id ?? b.taskId ?? b.id ?? null;
    if (!task_id) return res.status(400).json({ ok: false, error: "task_id_required" });

    const evt = await emitTaskEvent({
      pool,
      pool,
      kind: "task.canceled",
      task_id,
      run_id: b.run_id ?? b.runId ?? null,
      actor: b.actor ?? "api",
      payload: {
        reason: b.reason ?? null,
        source: b.source ?? "api",
      },
    });

    res.status(200).json({ ok: true, task_id, event: evt });
  } catch (e) {
    console.error("[phase25] /api/tasks error", e);

    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

