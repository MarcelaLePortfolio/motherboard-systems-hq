// <0001fae6> Phase 9 — OPS SSE Live Polling (1Hz broadcast)
import express from "express";
import cors from "cors";
import Database from "better-sqlite3";
const app = express();
app.use(cors());
const db = new Database("db/main.db");
const clients = [];
let lastSentTask = 0;
app.get("/events/ops", (req, res) => {
    res.writeHead(200, {
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        Connection: "keep-alive",
    });
    res.write(`data: {"status":"connected"}\n\n`);
    clients.push(res);
    console.log(`<0001fae7> 🧩 OPS client connected (${clients.length} total)`);
    req.on("close", () => {
        const i = clients.indexOf(res);
        if (i !== -1)
            clients.splice(i, 1);
        console.log(`<0001fae8> ❌ OPS client disconnected (${clients.length} remaining)`);
    });
});
function broadcastNewTasks() {
    const rows = db
        .prepare("SELECT id, description, status, created_at FROM task_events WHERE id > ? ORDER BY id ASC")
        .all(lastSentTask);
    if (rows.length > 0) {
        lastSentTask = rows[rows.length - 1].id;
        const payload = JSON.stringify({ tasks: rows, ts: new Date().toISOString() });
        for (const client of clients)
            client.write(`data: ${payload}\n\n`);
        console.log(`<0001fae9> 🧠 Broadcasted ${rows.length} new tasks`);
    }
    else {
        for (const client of clients)
            client.write(`data: {"keepalive":true}\n\n`);
    }
}
setInterval(broadcastNewTasks, 1000);
app.listen(3201, () => {
    console.log("✅ OPS SSE server running at http://localhost:3201/events/ops");
});
