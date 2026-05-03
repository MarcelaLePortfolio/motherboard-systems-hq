import express from "express";
import { dbDelegateTask, dbCompleteTask } from "../tasks-mutations.mjs";

function _asJson(req) {
  const b = req.body;
  if (b == null) return {};
  if (typeof b === "object") return b;
  if (typeof b === "string") {
    try { return JSON.parse(b); } catch (_) { return { _raw: b }; }
  }
  return { _raw: b };
}

export const apiTasksMutationsRouter = express.Router();

apiTasksMutationsRouter.post("/delegate", async (req, res) => {
  try {
    const pool = globalThis.__DB_POOL;
    if (!pool) return res.status(500).json({ ok: false, error: "db_pool_not_initialized" });
    const row = await dbDelegateTask(pool, _asJson(req));
    res.status(201).json({ ok: true, task: row });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

apiTasksMutationsRouter.post("/complete", async (req, res) => {
  try {
    const pool = globalThis.__DB_POOL;
    if (!pool) return res.status(500).json({ ok: false, error: "db_pool_not_initialized" });
      const b = _asJson(req);
      const row = await dbCompleteTask(pool, {
        ...b,
        kind: b.kind ?? b.event_kind ?? b.eventKind ?? "task.completed",
      });
    res.status(200).json({ ok: true, task: row });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

apiTasksMutationsRouter.post("/fail", async (req, res) => {
  try {
    const pool = globalThis.__DB_POOL;
    if (!pool) return res.status(500).json({ ok: false, error: "db_pool_not_initialized" });
      const b = _asJson(req);
      const row = await dbCompleteTask(pool, {
      ...b,
        kind: b.kind ?? b.event_kind ?? b.eventKind ?? "task.failed",
      status: b.status ?? "failed",
      error: b.error ?? b.err ?? "unknown_error",
    });
    res.status(200).json({ ok: true, task: row });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

export default apiTasksMutationsRouter;
