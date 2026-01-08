import express from "express";

const router = express.Router();

function _intOrNull(v) {
  if (v == null) return null;
  const n = Number(v);
  if (!Number.isFinite(n)) return null;
  const i = Math.floor(n);
  return i >= 0 ? i : null;
}

function _sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function _sseWrite(res, { id, event, data }) {
  if (id != null) res.write(`id: ${id}\n`);
  if (event) res.write(`event: ${event}\n`);
  const payload = typeof data === "string" ? data : JSON.stringify(data);
  res.write(`data: ${payload}\n\n`);
}

router.get("/events/task-events", async (req, res) => {
  res.status(200);
  res.setHeader("Content-Type", "text/event-stream; charset=utf-8");
  res.setHeader("Cache-Control", "no-cache, no-transform");
  res.setHeader("Connection", "keep-alive");
  res.setHeader("X-Accel-Buffering", "no");
  res.flushHeaders?.();

  const pool = globalThis.__DB_POOL;
  try {
    const o = pool?.options || {};
    console.log("[task-events] pool cfg", {
      host: o.host || null,
      port: o.port || null,
      user: o.user || null,
      database: o.database || null,
      password_type: typeof o.password,
      password_len: (o.password == null ? null : String(o.password).length),
      has_password: (o.password != null),
    });
  } catch (_) {}

  if (!pool) {
    _sseWrite(res, { event: "error", data: { msg: "DB pool not initialized", ts: Date.now() } });
    res.end();
    return;
  }

  const headerLast = req.get("Last-Event-ID");
  const qAfter = req.query?.after;
  let cursor = _intOrNull(headerLast) ?? _intOrNull(qAfter) ?? null;

  _sseWrite(res, { event: "hello", data: { kind: "task-events", cursor, ts: Date.now() } });

  let closed = false;
  req.on("close", () => { closed = true; });

  let backoffMs = 150;
  const backoffMax = 1500;
  const batchLimit = 200;

  if (cursor == null) {
    try {
      const r = await pool.query(`select max(id) as max_id from task_events`);
      cursor = _intOrNull(r?.rows?.[0]?.max_id) ?? 0;
    } catch (_) {
      cursor = 0;
    }
  }

  while (!closed) {
    try {
      const q = await pool.query(
        `
        select
          id,
          task_id,
          type,
          ts,
          run_id,
          actor,
          meta
        from task_events
        where id > $1
        order by id asc
        limit $2
        `,
        [cursor, batchLimit]
      );

      const rows = q?.rows || [];
      if (rows.length === 0) {
        _sseWrite(res, { event: "heartbeat", data: { ts: Date.now(), cursor } });
        await _sleep(backoffMs);
        backoffMs = Math.min(backoffMs + 75, backoffMax);
        continue;
      }

      backoffMs = 150;

      for (const r of rows) {
        cursor = _intOrNull(r.id) ?? cursor;
        _sseWrite(res, {
          id: String(r.id),
          event: "task.event",
          data: {
            id: r.id,
            taskId: r.task_id,
            type: r.type,
            ts: r.ts,
            runId: r.run_id,
            actor: r.actor,
            meta: r.meta,
          },
        });
      }
    } catch (e) {
      _sseWrite(res, {
        event: "error",
        data: { msg: "task-events stream error", detail: e?.message || String(e), ts: Date.now() },
      });
      await _sleep(backoffMs);
      backoffMs = Math.min(Math.floor(backoffMs * 1.5), backoffMax);
    }
  }

  try { res.end(); } catch (_) {}
});

export default router;
