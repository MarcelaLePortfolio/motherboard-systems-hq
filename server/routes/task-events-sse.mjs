import express from "express";
import pg from "pg";
import { interpretCompletedTaskEvent } from "../execution_guidance_router.mjs";

const router = express.Router();
const { Pool } = pg;

const DB_URL = process.env.POSTGRES_URL || process.env.DATABASE_URL || null;

let pool = null;

function getPool() {
  if (pool) return pool;

  if (!DB_URL) {
    pool = new Pool({
      user: process.env.POSTGRES_USER || "postgres",
      host: process.env.DB_HOST || "postgres",
      database: process.env.POSTGRES_DB || "postgres",
      password: process.env.POSTGRES_PASSWORD || "postgres",
      port: 5432,
    });
    return pool;
  }

  pool = new Pool({ connectionString: DB_URL });
  return pool;
}

function intOrNull(value) {
  const n = Number(value);
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

function sseWrite(res, { event, data }) {
  if (event) res.write(`event: ${event}\n`);
  res.write(`data: ${JSON.stringify(data)}\n\n`);
  if (typeof res.flush === "function") {
    res.flush();
  }
}

function normalizeKind(kind) {
  const v = String(kind || "").trim();
  return v || "task.event";
}

function normalizeRow(row) {
  const payload =
    row && row.payload && typeof row.payload === "object" && !Array.isArray(row.payload)
      ? row.payload
      : {};

  const kind = normalizeKind(row?.kind);

  return {
    ...payload,
    id: row?.id ?? null,
    task_id: row?.task_id ?? payload.task_id ?? payload.taskId ?? null,
    taskId: row?.task_id ?? payload.taskId ?? payload.task_id ?? null,
    kind,
    actor: row?.actor ?? payload.actor ?? null,
    run_id: row?.run_id ?? payload.run_id ?? payload.runId ?? null,
    runId: row?.run_id ?? payload.runId ?? payload.run_id ?? null,
    ts: Number(row?.ts ?? payload.ts ?? Date.now()),
    created_at: row?.created_at ?? payload.created_at ?? null
  };
}

router.get("/events/task-events", async (req, res) => {
  res.setHeader("Content-Type", "text/event-stream; charset=utf-8");
  res.setHeader("Cache-Control", "no-cache, no-transform");
  res.setHeader("Connection", "keep-alive");

  const db = getPool();

  let cursor = intOrNull(req.query.cursor) ?? 0;

  const poll = async () => {
    const result = await db.query(
      `
      select *
      from task_events
      where coalesce(ts, (extract(epoch from created_at) * 1000)::bigint) > $1
      order by ts asc, id asc
      limit 200
      `,
      [cursor]
    );

    for (const row of result.rows) {
      const payload = normalizeRow(row);

      let enrichedPayload = payload;

      try {
        if (row.kind === "task.completed") {
          const guidance = interpretCompletedTaskEvent({ ...row, payload });
          if (guidance) {
            enrichedPayload = { ...payload, guidance };
          }
        }
      } catch {}

      sseWrite(res, {
        event: normalizeKind(row.kind),
        data: enrichedPayload
      });

      const nextCursor = intOrNull(payload.ts);
      if (nextCursor && nextCursor > cursor) cursor = nextCursor;
    }
  };

  setInterval(() => void poll(), 800);
});

export default router;
