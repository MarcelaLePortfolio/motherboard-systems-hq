
import express from "express";

import pg from "pg";

import { interpretCompletedTaskEvent } from "../execution_guidance_router.mjs";

import { normalizeTaskEvent } from "../core/task_event_normalizer.mjs";

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

function normalizeKind(kind) {

  return String(kind || "").trim() || "task.event";

}

function normalizeRow(row) {

  const payload =

    row?.payload && typeof row.payload === "object" && !Array.isArray(row.payload)

      ? row.payload

      : {};

  const kind = normalizeKind(row?.kind);

  return {

    ...payload,

    task_id: row?.task_id ?? payload.task_id ?? payload.taskId ?? null,

    kind,

    actor: row?.actor ?? payload.actor ?? null,

    ts: Number(row?.ts ?? Date.now())

  };

}

function maybeAttachGuidance(row, payload, eventName) {

  if (eventName !== "task.completed") return payload;

  try {

    const guidance = interpretCompletedTaskEvent({ ...row, payload });

    return guidance ? { ...payload, guidance } : payload;

  } catch {

    return payload;

  }

}

function sseWrite(res, { event, data }) {

  if (event) res.write(`event: ${event}\n`);

  res.write(`data: ${JSON.stringify(data)}\n\n`);

}

router.get("/events/task-events", async (req, res) => {

  res.setHeader("Content-Type", "text/event-stream");

  const db = getPool();

  if (!db) {

    res.write(`data: ${JSON.stringify({ error: "no db" })}\n\n`);

    return res.end();

  }

  let cursor = 0;

  res.write(`: connected\n\n`);

  const poll = async () => {

    const result = await db.query(

      `select * from task_events where ts > $1 order by ts asc limit 100`,

      [cursor]

    );

    for (const row of result.rows) {

      const payload = normalizeRow(row);

      const eventName = normalizeKind(row.kind);

      const enrichedPayload = maybeAttachGuidance(row, payload, eventName);

      const normalized = normalizeTaskEvent({

        task_id: enrichedPayload.task_id,

        agent_id: enrichedPayload.actor,

        status: enrichedPayload.kind,

        ts: enrichedPayload.ts

      });

      const systemMeta = maybeAttachGuidance(row, payload, eventName);

      sseWrite(res, {

        event: "mb.task.event",

        data: {

          ui: normalized,

          system: systemMeta || null

        }

      });

      cursor = Math.max(cursor, payload.ts);

    }

  };

  const interval = setInterval(poll, 1000);

  req.on("close", () => {

    clearInterval(interval);

    res.end();

  });

});

export default router;

