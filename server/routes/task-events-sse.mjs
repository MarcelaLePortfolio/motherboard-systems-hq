import express from "express";
import pg from "pg";

const router = express.Router();
const { Pool } = pg;

const DB_URL = process.env.POSTGRES_URL || process.env.DATABASE_URL || "";

let pool = null;

function getPool() {
  if (pool) return pool;
  if (!DB_URL) return null;
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

router.get("/api/task-events-sse", (req, res) => {
  res.redirect(307, "/events/task-events");
});

router.get("/events/task-events", async (req, res) => {
  res.setHeader("Content-Type", "text/event-stream; charset=utf-8");
  res.setHeader("Cache-Control", "no-cache, no-transform");
  res.setHeader("Connection", "keep-alive");
  res.setHeader("X-Accel-Buffering", "no");

  if (typeof res.flushHeaders === "function") {
    res.flushHeaders();
  }

  try {
    req.socket.setTimeout(0);
    res.socket.setTimeout(0);
    res.socket.setKeepAlive(true);
  } catch {}

  const db = getPool();

  if (!db) {
    sseWrite(res, {
      event: "error",
      data: {
        kind: "task-events",
        msg: "missing POSTGRES_URL/DATABASE_URL",
        ts: Date.now()
      }
    });
    res.end();
    return;
  }

  let closed = false;
  let polling = false;

  const requestedCursor =
    intOrNull(req.query.cursor) ??
    intOrNull(req.query.since) ??
    intOrNull(req.query.ts);

  let cursor = requestedCursor;

  try {
    if (cursor == null) {
      const seed = await db.query(
        `
        select coalesce(max(ts), 0)::bigint as cursor
        from task_events
        `
      );
      cursor = intOrNull(seed.rows?.[0]?.cursor) ?? 0;
    }

    res.write(`: connected ${new Date().toISOString()}\n\n`);

    sseWrite(res, {
      event: "hello",
      data: {
        kind: "task-events",
        cursor,
        ts: Date.now()
      }
    });

    const heartbeat = setInterval(() => {
      if (closed) return;
      res.write(`: heartbeat ${new Date().toISOString()}\n\n`);
      sseWrite(res, {
        event: "heartbeat",
        data: {
          ts: Date.now(),
          cursor
        }
      });
    }, 15000);

    const poll = async () => {
      if (closed || polling) return;
      polling = true;

      try {
        const result = await db.query(
          `
          select
            id,
            task_id,
            kind,
            actor,
            payload,
            run_id,
            created_at,
            coalesce(ts, (extract(epoch from created_at) * 1000)::bigint) as ts
          from task_events
          where coalesce(ts, (extract(epoch from created_at) * 1000)::bigint) > $1
          order by coalesce(ts, (extract(epoch from created_at) * 1000)::bigint) asc, id asc
          limit 200
          `,
          [cursor]
        );

        for (const row of result.rows) {
          const payload = normalizeRow(row);
          const eventName = normalizeKind(row.kind);

          sseWrite(res, {
            event: eventName,
            data: payload
          });

          sseWrite(res, {
            event: "task.event",
            data: payload
          });

          const nextCursor = intOrNull(payload.ts);
          if (nextCursor != null && nextCursor > cursor) {
            cursor = nextCursor;
          }
        }
      } catch (err) {
        sseWrite(res, {
          event: "error",
          data: {
            kind: "task-events",
            msg: "task-events stream error",
            detail: err?.message || String(err),
            ts: Date.now(),
            cursor
          }
        });
      } finally {
        polling = false;
      }
    };

    const interval = setInterval(() => {
      void poll();
    }, 800);

    void poll();

    req.on("close", () => {
      closed = true;
      clearInterval(interval);
      clearInterval(heartbeat);
      res.end();
    });
  } catch (err) {
    sseWrite(res, {
      event: "error",
      data: {
        kind: "task-events",
        msg: "task-events stream bootstrap error",
        detail: err?.message || String(err),
        ts: Date.now(),
        cursor: cursor ?? 0
      }
    });
    res.end();
  }
});

export default router;
