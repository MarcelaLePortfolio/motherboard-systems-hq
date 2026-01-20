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

  // GET /api/tasks?limit=25  -> recent tasks for dashboard widget
  apiTasksRouter.get("/", async (req, res) => {
    try {
      const pool = _getPoolOrFail(res); if (!pool) return;
      const limit = Math.max(1, Math.min(200, Number(req.query?.limit ?? 25) || 25));
      const r = await pool.query(
        `
        SELECT id, task_id, title, status, agent, updated_at
        FROM tasks
        ORDER BY updated_at DESC NULLS LAST, id DESC
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


// POST /api/tasks/create  { task_id?, title?, agent?, run_id?, ... }
apiTasksRouter.post("/create", async (req, res) => {
  try {
    const pool = _getPoolOrFail(res); if (!pool) return;
      console.log("[phase25] /api/tasks/create pool snapshot", { hasLocal: !!pool, localType: pool?.constructor?.name, hasGlobal: !!globalThis.__DB_POOL, globalType: globalThis.__DB_POOL?.constructor?.name });

    const b = _asJson(req);


    // Accept caller-provided task_id; otherwise create a task row + mint a stable string task_id.

    let task_id = b.task_id ?? b.taskId ?? b.id ?? null;


    if (!task_id) {

      const title  = b.title  ?? b.kind ?? "untitled";

      const agent  = b.agent  ?? null;

      const status = b.status ?? "queued";

      const source = b.source ?? "api";


      // store arbitrary request details in meta (jsonb)

      const meta = {

        kind: b.kind ?? null,

        payload: b.payload ?? null,

        notes: b.notes ?? null,

        trace_id: b.trace_id ?? b.traceId ?? null,

        raw: b,

      };


      const created = await pool.query(

        `

        INSERT INTO tasks(title, agent, status, source, trace_id, meta)

        VALUES ($1, $2, $3, $4, $5, $6::jsonb)

        RETURNING id

        `,

        [title, agent, status, source, meta.trace_id, meta]

      );


      const id = created.rows?.[0]?.id ?? null;

      if (id == null) throw new Error("phase25: failed to create tasks.id");


      task_id = `t${id}`;


      await pool.query(

        `UPDATE tasks SET task_id = $1 WHERE id = $2`,

        [task_id, id]

      );

    }


    // Normalize to string for lifecycle events

    task_id = String(task_id);

const evt = await emitTaskEvent({
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

