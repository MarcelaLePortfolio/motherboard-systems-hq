/**
 * Phase 16 — Optional SSE endpoints for dashboard (OPS + Reflections)
 * Routes:
 *   GET /events/ops
 *   GET /events/reflections
 *
 * Minimal, safe implementation:
 * - Proper SSE headers
 * - Immediate hello event
 * - Keepalive comment every 15s
 * - Broadcast helper (optional)
 */

function sseHeaders(res) {
  res.status(200);
  res.setHeader("Content-Type", "text/event-stream; charset=utf-8");
  res.setHeader("Cache-Control", "no-cache, no-transform");
  res.setHeader("Connection", "keep-alive");
  // Helpful behind proxies
  res.setHeader("X-Accel-Buffering", "no");
  if (typeof res.flushHeaders === "function") res.flushHeaders();
}

function writeEvent(res, { event, data }) {
  if (event) res.write(`event: ${event}\n`);
  if (data !== undefined) {
    const payload = typeof data === "string" ? data : JSON.stringify(data);
    // SSE requires each line in data be prefixed with "data:"
    const lines = String(payload).split("\n");
    for (const line of lines) res.write(`data: ${line}\n`);
  }
  res.write("\n");
}

function writeKeepalive(res) {
  // Comment line (ignored by clients) keeps connection open
  res.write(`: keepalive ${Date.now()}\n\n`);
}

function makeStream(kind) {
  const clients = new Set();

  function handler(req, res) {
    sseHeaders(res);

    clients.add(res);

    writeEvent(res, {
      event: "hello",
      data: { kind, ts: Date.now(), note: "Phase16 SSE online" },
    });

    const ka = setInterval(() => writeKeepalive(res), 15000);

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

  return { handler, broadcast, clients };
}

export function registerOptionalSSE(app) {
  if (!app || typeof app.get !== "function") {
    throw new Error("registerOptionalSSE expected an Express-like app with app.get()");
  }

  const ops = makeStream("ops");
  const reflections = makeStream("reflections");

  app.get("/events/ops", ops.handler);
  app.get("/events/reflections", reflections.handler);

  // Expose broadcasters for future wiring (optional)
  if (typeof globalThis.__SSE !== "object" || !globalThis.__SSE) globalThis.__SSE = {};
  globalThis.__SSE.ops = ops;
  globalThis.__SSE.reflections = reflections;

  return { ops, reflections };
}
