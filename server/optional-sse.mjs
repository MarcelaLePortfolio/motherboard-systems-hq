/**
 * Phase 16 — Optional SSE endpoints for dashboard (OPS + Reflections)
 *
 * Routes:
 *   GET /events/ops
 *   GET /events/reflections
 *
 * Guarantees:
 * - Proper SSE headers
 * - Immediate "hello" event (so curl never hangs silently)
 * - Keepalive comment every 15s (prevents idle timeouts)
 * - Broadcast helper exposed on globalThis.__SSE for future wiring
 */

function sseHeaders(res) {
  res.status(200);
  res.setHeader("Content-Type", "text/event-stream; charset=utf-8");
  res.setHeader("Cache-Control", "no-cache, no-transform");
  res.setHeader("Connection", "keep-alive");
  res.setHeader("X-Accel-Buffering", "no");
  // Express flushHeaders() exists; if not, ignore.
  try { res.flushHeaders(); } catch (_) {}
}

function writeLine(res, line) {
  res.write(line.endsWith("\n") ? line : line + "\n");
}

function writeEvent(res, { event, data, id } = {}) {
  if (id !== undefined && id !== null) writeLine(res, `id: ${id}`);
  if (event) writeLine(res, `event: ${event}`);
  const payload =
    typeof data === "string" ? data :
    data === undefined ? "" :
    JSON.stringify(data);
  // SSE supports multi-line data: prefix each line with "data:"
  String(payload).split("\n").forEach((ln) => writeLine(res, `data: ${ln}`));
  writeLine(res, "");
}

function makeStream(kind) {
  const clients = new Set();

  function handler(req, res) {
    sseHeaders(res);

    // Register client
    clients.add(res);

    // Immediate hello so clients receive bytes instantly
    writeEvent(res, {
      event: "hello",
      data: { kind, ts: Date.now(), msg: `SSE ${kind} connected` },
    });





    if (once) {
      // One-shot mode for curl smoke tests: send hello and close.
      setTimeout(() => {
        try { res.end(); } catch (_) {}
      }, 25);
      return;
    }
    if (once) {
      // One-shot mode for curl smoke tests: send hello and close.
      setTimeout(() => {
        try { res.end(); } catch (_) {}
      }, 25);
      return;
    }
    if (once) {
      // One-shot mode for curl smoke tests: send hello and close.
      setTimeout(() => {
        try { res.end(); } catch (_) {}
      }, 25);
      return;
    }
    // If ?once=1, end immediately after hello for clean curl tests.
    try {
      const url = new URL(req.originalUrl || req.url || "/", "http://localhost");
      if (url.searchParams.get("once") === "1") {
        try { res.end(); } catch (_) {}
        return;
      }
    } catch (_) {}
    // Keepalive comment (":" lines are ignored by SSE clients)
    const ka = setInterval(() => {
      try { writeLine(res, `:ka ${Date.now()}`); writeLine(res, ""); } catch (_) {}
    }, 15000);

    req.on("close", () => {
      clearInterval(ka);
      clients.delete(res);
      try { res.end(); } catch (_) {}
    });
  }

  function broadcast(event, data) {
    for (const res of clients) {
      try {
        writeEvent(res, { event, data });
      } catch (_) {
        try { res.end(); } catch (_) {}
        clients.delete(res);
      }
    }
  }

  return { kind, handler, broadcast, clients };
}

export function registerOptionalSSE(app) {
  if (!app || typeof app.get !== "function") {
    throw new Error("registerOptionalSSE expected an Express-like app with app.get()");
  }

  const ops = makeStream("ops");
  const reflections = makeStream("reflections");

  app.get("/events/ops", ops.handler);
  app.get("/events/reflections", reflections.handler);

  // Expose for future use (e.g., globalThis.__SSE.ops.broadcast("pm2-status", {...}))
  if (!globalThis.__SSE || typeof globalThis.__SSE !== "object") globalThis.__SSE = {};
  globalThis.__SSE.ops = ops;
  globalThis.__SSE.reflections = reflections;

  return { ops, reflections };
}
