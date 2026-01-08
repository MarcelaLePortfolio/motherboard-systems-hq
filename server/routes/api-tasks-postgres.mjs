import express from "express";
import { emitTaskEvent } from "../task_events_emit.mjs";

export const apiTasksRouter = express.Router();

// POST /api/tasks/health
apiTasksRouter.get("/health", async (req, res) => {
  try {
    // If emitTaskEvent can write, DB is up; but health should be non-writing.
    // We keep this simple and return ok=true; deeper DB checks live elsewhere.
    res.status(200).json({ ok: true });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

// POST /api/tasks/create  { task_id?, title?, agent?, run_id?, ... }
apiTasksRouter.post("/create", async (req, res) => {
  try {
    const b = req.body || {};
    const task_id = b.task_id ?? b.taskId ?? b.id ?? null;

    const evt = await emitTaskEvent({
      kind: "task.created",
      task_id,
      run_id: b.run_id ?? b.runId ?? null,
      actor: b.actor ?? "api",
      payload: {
        title: b.title ?? null,
        agent: b.agent ?? null,
        status: b.status ?? "delegated",
        meta: b.meta ?? null,
      },
    });

    res.status(201).json({ ok: true, task_id, event: evt });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

// POST /api/tasks/complete  { task_id, status?, run_id?, ... }
apiTasksRouter.post("/complete", async (req, res) => {
  try {
    const b = req.body || {};
    const task_id = b.task_id ?? b.taskId ?? b.id ?? null;
    if (!task_id) return res.status(400).json({ ok: false, error: "task_id_required" });

    const evt = await emitTaskEvent({
      kind: "task.completed",
      task_id,
      run_id: b.run_id ?? b.runId ?? null,
      actor: b.actor ?? "api",
      payload: {
        status: b.status ?? "complete",
        result: b.result ?? null,
      },
    });

    res.status(200).json({ ok: true, task_id, event: evt });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

// POST /api/tasks/fail  { task_id, error?, status?, run_id?, ... }
apiTasksRouter.post("/fail", async (req, res) => {
  try {
    const b = req.body || {};
    const task_id = b.task_id ?? b.taskId ?? b.id ?? null;
    if (!task_id) return res.status(400).json({ ok: false, error: "task_id_required" });

    const evt = await emitTaskEvent({
      kind: "task.failed",
      task_id,
      run_id: b.run_id ?? b.runId ?? null,
      actor: b.actor ?? "api",
      payload: {
        status: b.status ?? "failed",
        error: b.error ?? b.err ?? null,
      },
    });

    res.status(200).json({ ok: true, task_id, event: evt });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

// POST /api/tasks/cancel  { task_id, run_id?, ... }
apiTasksRouter.post("/cancel", async (req, res) => {
  try {
    const b = req.body || {};
    const task_id = b.task_id ?? b.taskId ?? b.id ?? null;
    if (!task_id) return res.status(400).json({ ok: false, error: "task_id_required" });

    const evt = await emitTaskEvent({
      kind: "task.canceled",
      task_id,
      run_id: b.run_id ?? b.runId ?? null,
      actor: b.actor ?? "api",
      payload: {
        reason: b.reason ?? null,
      },
    });

    res.status(200).json({ ok: true, task_id, event: evt });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});
