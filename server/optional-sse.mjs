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

function writeEvent(res, evt = {}) {
  // PHASE16_WRITE_EVENT_EVT_SIGNATURE
  let { event, data, id } = (evt || {});
  // Normalize hub messages like { type, payload }
  if (evt && typeof evt === "object" && typeof evt.type === "string" && event == null) {
    event = evt.type;
    data = (evt.payload !== undefined ? evt.payload : evt);
  }

  // PHASE16_WRITE_EVENT_FIX_SWAPPED
  // Some callers accidentally pass { event: <msgObject>, data: <msgTypeString> }.
  // If so, swap/normalize so SSE "event:" is a string and "data:" is the payload.
  if (event && typeof event === "object" && typeof data === "string") {
    const maybe = event;
    if (typeof maybe.type === "string" && data === maybe.type) {
      event = maybe.type;
      data = (maybe.payload !== undefined ? maybe.payload : maybe);
    } else if (typeof maybe.type === "string" && data.includes(".") && data === maybe.type) {
      event = maybe.type;
      data = (maybe.payload !== undefined ? maybe.payload : maybe);
    } else if (typeof maybe.type === "string" && data.includes(".")) {
      // If data *looks* like an event name, treat it as the event anyway.
      event = data;
      data = (maybe.payload !== undefined ? maybe.payload : maybe);
    }
  }

  // PHASE16_WRITE_EVENT_NORMALIZE_SHAPE
  // Allow hub messages like { type, payload } by mapping them to { event, data }.
  // This prevents "event: [object Object]" and yields "event: ops.agent_status", etc.
  if (event == null && data == null) {
    try {
      // Best-effort: if someone passed { type, payload } as the *second arg object*,
      // we can still reconstruct via arguments.callee caller patterns are messy.
      // Instead, we rely on callers using writeEvent(res, msg) where msg has type/payload.
    } catch (_) {}
  }

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






      
      


      // PHASE16_OPTIONAL_SSE_SNAPSHOT_ON_CONNECT
      // Send an immediate state snapshot so the dashboard can paint instantly.
      // (Only OPS has a defined global state today.)
      try {
        if (kind === "ops" && globalThis.__OPS_STATE) {
          writeEvent(res, { event: "ops.state", data: globalThis.__OPS_STATE });
        }
      } catch (_) {}

      // PHASE16_OPTIONAL_SSE_ONCE_DEFINED
      // If ?once=1, end immediately after hello/snapshot for clean curl smoke tests.
      let once = false;
      try {
        const url = new URL(req.originalUrl || req.url || "/", "http://localhost");
        once = url.searchParams.get("once") === "1";
      } catch (_) {}
      if (once) {
        setTimeout(() => { try { res.end(); } catch (_) {} }, 25);
        return;
      }

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
