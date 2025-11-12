import express from "express";



// <0001fae2> Phase 9 — Reflection SSE Live Polling (1Hz broadcast)

import cors from "cors";
import Database from "better-sqlite3";

const app = (express as any)();
app.use(cors());
const db = new Database("db/main.db");
const clients: express.Response[] = [];
let lastSentId = 0;

app.get("/events/reflections", (req: express.Request, res: express.Response) => {
  (<any>res).writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });
  res.write(`data: {"status":"connected"}\n\n`);
  clients.push(res);
  console.log(`<0001fae3> 🧩 New SSE client connected (${clients.length} total)`);

  req.on("close", () => {
    const i = clients.indexOf(res);
    if (i !== -1) clients.splice(i, 1);
    console.log(`<0001fae4> ❌ SSE client disconnected (${clients.length} remaining)`);
  });
});

function broadcastNewReflections() {
  const rows = db
    .prepare("SELECT id, content, created_at FROM reflection_index WHERE id > ? ORDER BY id ASC")
    .all(lastSentId);

  if (rows.length > 0) {
    lastSentId = rows[rows.length - 1].id;
    const payload = JSON.stringify({ reflections: rows, ts: new Date().toISOString() });
    for (const client of clients) client.write(`data: ${payload}\n\n`);
    console.log(`<0001fae5> 🧠 Broadcasted ${rows.length} new reflections`);
  } else {
    for (const client of clients) client.write(`data: {"keepalive":true}\n\n`);
  }
}

// Poll the DB every second
setInterval(broadcastNewReflections, 1000);

app.listen(3101, () => {
  console.log("✅ Reflection SSE server running at http://localhost:3101/events/reflections");
});
