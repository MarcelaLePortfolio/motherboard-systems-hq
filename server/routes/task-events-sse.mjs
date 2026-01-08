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
    res.status(500).setHeader("Content-Type", "text/plain; charset=utf-8");
    res.end("Missing globalThis.__DB_POOL");
    return;
  }

res.status(200);
  res.setHeader("Content-Type", "text/event-stream; charset=utf-8");
  res.setHeader("Cache-Control", "no-cache, no-transform");
  res.setHeader("Connection", "keep-alive");
  res.setHeader("X-Accel-Buffering", "no");
  res.flushHeaders?.();

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
    _sseWrite(res, { event: "error", data: (schemaMode === "wide"
            ? {
                id: r.id,
                taskId: r.task_id,
                type: r.type,
                ts: r.ts,
                runId: r.run_id,
                actor: r.actor,
                meta: r.meta,
              }
            : {
                id: r.id,
                taskId: (r.payload?.task_id ?? r.payload?.taskId ?? null),
                type: r.kind,
                ts: (r.payload?.ts ?? Date.now()),
                runId: (r.payload?.run_id ?? r.payload?.runId ?? null),
                actor: (r.payload?.actor ?? null),
                meta: r.payload ?? null,
              }),
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
