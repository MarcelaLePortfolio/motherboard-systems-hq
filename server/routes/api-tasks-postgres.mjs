import express from "express";
import pg from "pg";

const { Pool } = pg;

function poolCfg() {
  return {
    host: process.env.PGHOST || "postgres",
    port: Number(process.env.PGPORT || 5432),
    user: process.env.PGUSER || "postgres",
    password: process.env.PGPASSWORD || "postgres",
    database: process.env.PGDATABASE || "postgres",
  };
}

const pool = new Pool(poolCfg());

async function ensureTaskEvents() {
  // Phase19 reality: public.task_events(kind text not null, payload text not null, created_at text default now()::text)
  // Keep this idempotent.
  await pool.query(`
    create table if not exists public.task_events (
      id bigserial primary key,
      kind text not null,
      payload text not null,
      created_at text default now()::text
    );
  `);
}

async function append(kind, payloadObj) {
  const payload = JSON.stringify(payloadObj ?? {});
  const r = await pool.query(
    "insert into public.task_events (kind, payload) values ($1, $2) returning id, kind, payload, created_at",
    [String(kind), String(payload)]
  );
  return r.rows[0];
}

export const apiTasksRouter = express.Router();

apiTasksRouter.get("/healthz", async (_req, res) => {
  try {
    const r = await pool.query("select 1 as ok");
    res.status(200).json({ ok: true, db: r.rows?.[0]?.ok === 1 });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

// POST /api/tasks/create  { task_id?, title?, ... }
apiTasksRouter.post("/create", async (req, res) => {
  try {
    await ensureTaskEvents();
    const b = req.body || {};
    const task_id = b.task_id ?? b.id ?? null;

    const evt = await append("task.created", {
      task_id,
      ts: Date.now(),
      source: "api",
      ...b,
    });

    res.status(201).json({ ok: true, task_id, event: evt });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

// POST /api/tasks/complete  { task_id, status?, ... }
apiTasksRouter.post("/complete", async (req, res) => {
  try {
    await ensureTaskEvents();
    const b = req.body || {};
    const task_id = b.task_id ?? b.id ?? null;
    if (!task_id) return res.status(400).json({ ok: false, error: "task_id_required" });

    const evt = await append("task.completed", {
      task_id,
      status: b.status ?? "done",
      error: b.error ?? null,
      ts: Date.now(),
      source: "api",
      ...b,
    });

    res.status(200).json({ ok: true, task_id, event: evt });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

// POST /api/tasks/fail  { task_id, error?, ... }
apiTasksRouter.post("/fail", async (req, res) => {
  try {
    await ensureTaskEvents();
    const b = req.body || {};
    const task_id = b.task_id ?? b.id ?? null;
    if (!task_id) return res.status(400).json({ ok: false, error: "task_id_required" });

    const evt = await append("task.failed", {
      task_id,
      status: b.status ?? "failed",
      error: b.error ?? "unknown_error",
      ts: Date.now(),
      source: "api",
      ...b,
    });

    res.status(200).json({ ok: true, task_id, event: evt });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});

// POST /api/tasks/cancel  { task_id, ... }
apiTasksRouter.post("/cancel", async (req, res) => {
  try {
    await ensureTaskEvents();
    const b = req.body || {};
    const task_id = b.task_id ?? b.id ?? null;
    if (!task_id) return res.status(400).json({ ok: false, error: "task_id_required" });

    const evt = await append("task.canceled", {
      task_id,
      ts: Date.now(),
      source: "api",
      ...b,
    });

    res.status(200).json({ ok: true, task_id, event: evt });
  } catch (e) {
    res.status(500).json({ ok: false, error: e?.message || String(e) });
  }
});
