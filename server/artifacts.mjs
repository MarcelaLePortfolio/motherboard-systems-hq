/**
 * Artifacts SSE + small in-memory replay.
 * No client synthesis: artifacts must originate server-side.
 */

const clients = new Set(); // res objects
let ring = [];
const RING_MAX = 100;

export function attachArtifacts(app) {
  app.get("/events/artifacts", (req, res) => {
    res.status(200);
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache, no-transform");
    res.setHeader("Connection", "keep-alive");
    res.flushHeaders?.();

    clients.add(res);

    // replay
    for (const a of ring) {
      res.write(`data: ${JSON.stringify(a)}\n\n`);
    }

    req.on("close", () => {
      clients.delete(res);
      try { res.end(); } catch {}
    });
  });

  // optional explicit publish endpoint (handy for testing)
  app.post("/api/artifacts", (req, res) => {
    emitArtifact({
      ...(req.body || {}),
      timestamp: new Date().toISOString(),
    });
    res.json({ ok: true });
  });

  return { emitArtifact };
}

export function emitArtifact(artifact) {
  // normalize + ring buffer
  const a = {
    type: artifact?.type || "log",
    source: artifact?.source || "unknown",
    taskId: artifact?.taskId,
    timestamp: artifact?.timestamp || new Date().toISOString(),
    payload: artifact?.payload ?? {},
  };

  ring.push(a);
  if (ring.length > RING_MAX) ring = ring.slice(-RING_MAX);

  for (const res of clients) {
    try {
      res.write(`data: ${JSON.stringify(a)}\n\n`);
    } catch {
      clients.delete(res);
    }
  }
}
