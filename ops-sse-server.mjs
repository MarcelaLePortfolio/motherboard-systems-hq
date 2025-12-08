import express from "express";

const PORT = 3201;

// Minimal Express app for OPS SSE
const app = express();

// Track connected SSE clients
const clients = new Map();

/**
 * Helper to send a single SSE event
 * as:  data: <json>\n\n
 */
function sendEvent(res, data) {
  res.write(`data: ${JSON.stringify(data)}\n\n`);
}

// OPS SSE endpoint
app.get("/events/ops", (req, res) => {
  console.log("🔌 OPS SSE client connected");

  // Standard SSE headers
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  // Allow dashboard on a different port to connect
  res.setHeader("Access-Control-Allow-Origin", "*");

  // Send an initial hello so the browser sees something immediately
  sendEvent(res, { type: "hello", source: "ops-sse", ts: Date.now() });

  const id = Date.now() + "-" + Math.random().toString(16).slice(2);
  clients.set(id, res);

  // Clean up when client disconnects
  req.on("close", () => {
    console.log("❌ OPS SSE client disconnected:", id);
    clients.delete(id);
  });
});

// Simple heartbeat every 5s so listeners stay warm
setInterval(() => {
  const payload = {
    type: "heartbeat",
    ts: Date.now(),
    message: "OPS SSE alive",
  };
  for (const [, res] of clients) {
    try {
      sendEvent(res, payload);
    } catch (err) {
      console.warn("⚠️ Failed to send heartbeat to a client:", err);
    }
  }
}, 5000);

app.listen(PORT, () => {
  console.log(`✅ OPS SSE server listening on http://localhost:${PORT}/events/ops`);
});
