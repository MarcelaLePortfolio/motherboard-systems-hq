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

function _safeJsonParse(s) {
  if (s == null) return null;
  if (typeof s !== "string") return s;
  try { return JSON.parse(s); } catch (_) { return s; }
}

router.get("/api/task-events-sse", (req, res) => {
    res.redirect(307, "/events/task-events");
  });

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

  let closed = false;
  req.on("close", () => { closed = true; });

  let backoffMs = 150;
  const backoffMax = 1500;
  const batchLimit = 200;

  // If first connect, start from latest so we don't dump the whole table by default.
  if (cursor == null) {
      try {
        const r = await pool.query(`
          select coalesce((extract(epoch from max(created_at)) * 1000)::bigint, 0) as max_ms
          from task_events
        `);
        cursor = _intOrNull(r?.rows?.[0]?.max_ms) ?? 0;
      } catch (_) {
        cursor = 0;
      }
    }

    _sseWrite(res, { event: "hello", data: { kind: "task-events", cursor, ts: Date.now() } });

  while (!closed) {
    try {
      let q;
        try {
          q = await pool.query(
          `
          select id, kind, payload, task_id, run_id, actor, created_at
          from task_events
          where created_at > to_timestamp($1 / 1000.0)
          order by created_at asc
          limit $2
          `,
            [cursor, batchLimit]
          );
        } catch (_e) {
          q = await pool.query(
          `
          select id, kind, payload, created_at
          from task_events
          where created_at > to_timestamp($1 / 1000.0)
          order by created_at asc
          limit $2
          `,
            [cursor, batchLimit]
          );
        }

const rows = q?.rows || [];
      if (rows.length === 0) {
        _sseWrite(res, { event: "heartbeat", data: { ts: Date.now(), cursor } });
        await _sleep(backoffMs);
        backoffMs = Math.min(backoffMs + 75, backoffMax);
        continue;
      }

      backoffMs = 150;

      for (const r of rows) {
        const _ms = (r.created_at instanceof Date) ? r.created_at.getTime() : Date.parse(r.created_at);
          if (Number.isFinite(_ms)) cursor = Math.max(cursor, _ms);
        const payload = _safeJsonParse(r.payload);
          const taskIdCol = (r.task_id ?? null);
          const runIdCol  = (r.run_id  ?? null);
          const actorCol  = (r.actor   ?? null);

        _sseWrite(res, {
          id: String(r.id),
          event: "task.event",
          data: {
            id: r.id,
            type: r.kind,
            ts: (payload?.ts ?? Date.now()),
            taskId: (taskIdCol ?? payload?.taskId ?? payload?.task_id ?? null),
            runId: (runIdCol ?? payload?.runId ?? payload?.run_id ?? null),
            actor: (actorCol ?? payload?.actor ?? payload?.owner ?? null),
            meta: payload,
            createdAt: r.created_at ?? null,
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
