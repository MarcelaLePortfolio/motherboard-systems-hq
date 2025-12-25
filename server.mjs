import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import pg from "pg";
import { attachArtifacts } from "./server/artifacts.mjs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(express.json());

const { emitArtifact } = attachArtifacts(app);
const PORT = process.env.PORT || 3000;

const { Pool } = pg;
const pool = new Pool({
  host: process.env.PGHOST || "postgres",
  port: Number(process.env.PGPORT || 5432),
  user: process.env.PGUSER || "postgres",
  password: process.env.PGPASSWORD || "postgres",
  database: process.env.PGDATABASE || "postgres",
});

console.log("Database pool initialized");

let lastOpsHeartbeat = Date.now();

// ---- Static dashboard assets ----
app.use("/public", express.static(path.join(__dirname, "public")));
app.get("/bundle.js", (req, res) => res.sendFile(path.join(__dirname, "public", "bundle.js")));
app.get("/bundle.js.map", (req, res) => res.sendFile(path.join(__dirname, "public", "bundle.js.map")));
app.get("/dashboard", (req, res) => res.sendFile(path.join(__dirname, "public", "dashboard.html")));
app.get("/", (req, res) => res.redirect("/dashboard"));

// ---- Tasks API ----
app.get("/api/tasks", async (req, res) => {
  try {
    const r = await pool.query(
      `select id::text, title, agent, status, notes, source, trace_id, error, meta, created_at, updated_at
       from tasks
       order by id desc`
    );
    res.json({ tasks: r.rows, source: "db-tasks" });
  } catch (e) {
    res.status(500).json({ error: String(e) });
  }
});

// ---- Phase 15: minimal task mutation endpoints (artifact-first) ----
// Note: These do NOT modify the DB yet. They exist to prove "real artifacts" wiring end-to-end.
// Next step after this: actually insert/update tasks in Postgres and emit the returned row.
app.post("/api/delegate-task", async (req, res) => {
  const body = req.body || {};
  const task = {
    id: body.taskId || body.id || null,
    title: body.title || "(untitled)",
    agent: body.agent || "cade",
    notes: body.notes || "",
  };

  const payload = { ok: true, action: "delegate", task };

  emitArtifact({
    type: "task_result",
    source: "cade",
    taskId: task.id,
    payload,
  });

  res.json(payload);
});

app.post("/api/complete-task", async (req, res) => {
  const body = req.body || {};
  const taskId = body.taskId || body.id || null;

  const payload = { ok: true, action: "complete", taskId };

  emitArtifact({
    type: "task_result",
    source: "cade",
    taskId,
    payload,
  });

  res.json(payload);
});

// ---- Tasks SSE ----
app.get("/events/tasks", async (req, res) => {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });

  // initial comment
  res.write(`: ready\n`);
  res.write(`:\n`);

  let closed = false;
  req.on("close", () => {
    closed = true;
  });

  const sendSnapshot = async () => {
    try {
      const r = await pool.query(
        `select id::text, title, agent, status, notes, source, trace_id, error, meta, created_at, updated_at
         from tasks
         order by id desc`
      );
      res.write(`data: ${JSON.stringify({ tasks: r.rows, source: "db-tasks", ts: Date.now() })}\n\n`);
    } catch (e) {
      res.write(`event: error\ndata: ${JSON.stringify({ error: String(e), ts: Date.now() })}\n\n`);
    }
  };

  // Send once immediately.
  await sendSnapshot();

  // Keepalive ping so clients always get periodic activity.
  const ping = setInterval(() => {
    if (closed) return;
    res.write(`: ping ${Date.now()}\n\n`);
  }, 5000);

  // Poll for changes.
  let lastHash = "";
  const poll = setInterval(async () => {
    if (closed) return;
    try {
      const r = await pool.query(
        `select id::text, title, agent, status, notes, source, trace_id, error, meta, created_at, updated_at
         from tasks
         order by id desc`
      );
      const payload = JSON.stringify(r.rows);
      if (payload !== lastHash) {
        lastHash = payload;
        res.write(`data: ${JSON.stringify({ tasks: r.rows, source: "db-tasks", ts: Date.now() })}\n\n`);
      }
    } catch (e) {
      res.write(`event: error\ndata: ${JSON.stringify({ error: String(e), ts: Date.now() })}\n\n`);
    }
  }, 2000);

  res.on("close", () => {
    clearInterval(ping);
    clearInterval(poll);
  });
});

// ---- Ops heartbeat (minimal, no SSE dependency) ----
app.get("/api/ops-heartbeat", (req, res) => {
  lastOpsHeartbeat = Date.now();
  res.json({ ok: true, ts: lastOpsHeartbeat });
});

// ---- Shared heartbeat snapshot (for debugging + potential UI hooks) ----
app.get("/api/heartbeat", (req, res) => {
  res.json({
    ok: true,
    ts: Date.now(),
    ops: { ts: lastOpsHeartbeat },
  });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});
