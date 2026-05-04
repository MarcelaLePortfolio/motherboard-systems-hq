/**
 * Artifacts SSE + small in-memory replay.
 * Artifacts must originate server-side (no client synthesis).
 */
const clients = new Set();
let ring = [];
const RING_MAX = 100;

function sseWrite(res, line) {
  try {
    res.write(line);
    res.flush?.();
  } catch {
    clients.delete(res);
  }
}

export function attachArtifacts(app) {
  app.get("/events/artifacts", (req, res) => {
  console.log("[ARTIFACTS] SSE client connected");
    res.status(200);
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache, no-transform");
    res.setHeader("Connection", "keep-alive");
    res.setHeader("X-Accel-Buffering", "no");
    res.flushHeaders?.();

    clients.add(res);

  console.log("[ARTIFACTS] clients=", clients.size);
    // immediate output so curl isn't a blank screen
    sseWrite(res, `: connected ${new Date().toISOString()}\n\n`);

    // replay
    for (const a of ring) {
      sseWrite(res, `data: ${JSON.stringify(a)}\n\n`);
    }

    req.on("close", () => {
    console.log("[ARTIFACTS] SSE client disconnected");
    console.log("[ARTIFACTS] clients=", clients.size);
      clients.delete(res);
      try { res.end(); } catch {}
    });
  });

  // keepalive ping (prevents buffering/timeouts)
  setInterval(() => {
    for (const res of clients) {
      sseWrite(res, `: ping ${new Date().toISOString()}\n\n`);
    }
  }, 15000);

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
    sseWrite(res, `data: ${JSON.stringify(a)}\n\n`);
  }
}
