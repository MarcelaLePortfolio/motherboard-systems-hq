import express from 'express';
import { fileURLToPath } from 'url';
import path from 'path';
import pg from 'pg';

const { Pool } = pg;

// Environment configuration
const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0'; // Bind to all interfaces for Docker

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

// JSON body parsing for dashboard POSTs
app.use(express.json());

// --- Next-2: in-memory store (dev stub) ------------------------------------
const __memStore = { tasks: [] };
function __nowIso() { return new Date().toISOString(); }
function __makeId() { return Math.floor(Date.now() / 1000); }
function __cap(arr, max) { while (arr.length > max) arr.pop(); }
// ---------------------------------------------------------------------------


// Database Connection Pool (may be unavailable locally; routes must degrade gracefully)
const pool = new Pool({
  user: process.env.POSTGRES_USER || 'postgres',
  host: process.env.DB_HOST || 'postgres', // docker-compose service name
  database: process.env.POSTGRES_DB || 'dashboard_db',
  password: process.env.POSTGRES_PASSWORD || 'password',
  port: 5432,
});

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// Explicit dashboard route
app.get('/dashboard', (_req, res) => {
  return res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
});

/**
 * Minimal compatibility stubs (Phase 11.x / Next-2)
 * These endpoints are referenced by various dashboard builds/branches.
 */
app.get('/api/status', (_req, res) => {
  const uptimeSeconds = Math.floor(process.uptime());
  return res.json({
    uptimeSeconds,
    health: 'ok',
    lastUpdated: new Date().toISOString(),
    source: 'stub-next2',
  });
});

// --- DB-backed Tasks (Phase 11.5) ------------------------------------------
async function __dbOk() {
  try {
    await pool.query("select 1 as ok");
    return true;
  } catch (_e) {
    return false;
  }
}

async function __ensureTasksSchema() {
  await pool.query(`
    create table if not exists tasks (
      id bigserial primary key,
      title text not null,
      agent text not null default 'cade',
      notes text not null default '',
      status text not null default 'delegated',
      created_at timestamptz not null default now(),
      updated_at timestamptz not null default now()
    );
    create index if not exists idx_tasks_created_at on tasks (created_at desc);
    create index if not exists idx_tasks_status on tasks (status);
  `);
}

async function __listTasks(limit = 50) {
  await __ensureTasksSchema();
  const r = await pool.query(
    "select id, title, agent, notes, status, created_at::text, updated_at::text from tasks order by created_at desc limit $1",
    [limit]
  );
  return r.rows;
}

app.get('/api/tasks', async (_req, res) => {
  try {
    if (!(await __dbOk())) return res.json({ tasks: __memStore.tasks, source: 'mem-next2' });
    const tasks = await __listTasks(50);
    return res.json({ tasks, source: 'db-tasks' });
  } catch (err) {
    console.error("/api/tasks failed:", err);
    return res.json({ tasks: __memStore.tasks, source: 'mem-next2' });
  }
});

app.post('/api/tasks', async (req, res) => {
  try {
    const body = req.body || {};
    const title = (typeof body.title === "string" && body.title.trim()) ? body.title.trim() : "";
    if (!title) return res.status(400).json({ error: "title is required", source: "db-tasks" });

    if (!(await __dbOk())) return res.status(503).json({ error: "db unavailable", source: "db-tasks" });

    await __ensureTasksSchema();
    const r = await pool.query(
      "insert into tasks (title, agent, notes, status) values ($1, $2, $3, $4) returning id, title, agent, notes, status, created_at::text, updated_at::text",
      [title, (body.agent || "cade"), (body.notes || ""), (body.status || "delegated")]
    );
    console.log("[task] CREATED", { id: r.rows[0].id, status: r.rows[0].status, agent: r.rows[0].agent, title: r.rows[0].title });
      return res.json({ task: r.rows[0], source: "db-tasks" });
  } catch (err) {
    console.error("/api/tasks POST failed:", err);
    return res.status(500).json({ error: "create failed", source: "db-tasks" });
  }
});
// ---------------------------------------------------------------------------

app.get('/api/logs', (_req, res) => {
  return res.json({
    logs: [],
    source: 'stub-next2',
  });
});

// 1) API Endpoint: System Metrics
app.get('/api/metrics', async (_req, res) => {
  try {
    const result = await pool.query('SELECT * FROM system_metrics ORDER BY id DESC LIMIT 1');
    if (result.rows.length > 0) return res.json(result.rows[0]);
    return res.status(404).json({ error: 'No metrics found' });
  } catch (err) {
    console.error(err);
    return res.json({ uptime: 0, cpu: 0, memory: 0, disk: 0, source: 'stub-db-down' });
  }
});

// 2) API Endpoint: Task Activity Graph
app.get('/api/activity-graph', async (_req, res) => {
  try {
    const result = await pool.query('SELECT * FROM task_activity ORDER BY timestamp ASC LIMIT 10');
    return res.json(result.rows);
  } catch (err) {
    console.error(err);
    return res.json([]);
  }
});

// 3) API Endpoint: Agent Status Row
app.get('/api/agents', async (_req, res) => {
  try {
    const result = await pool.query(
      'SELECT agent_name, status, current_task, last_heartbeat FROM agent_status ORDER BY status DESC, agent_name ASC'
    );
    return res.json(result.rows);
  } catch (err) {
    console.error(err);
    return res.json([]);
  }
});

// 4) API Endpoint: Task Delegation (DB-backed, optional)
app.post('/api/delegate-task-db', async (req, res) => {
  const client = await pool.connect();
  let assignedAgent = null;

  try {
    await client.query('BEGIN');

    const findAgentQuery =
      'SELECT agent_name FROM agent_status ' +
      "WHERE status = 'IDLE' " +
      'ORDER BY last_heartbeat ASC ' +
      'LIMIT 1 FOR UPDATE';

    const result = await client.query(findAgentQuery);

    if (result.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ message: 'No IDLE agents available.' });
    }

    const agentName = result.rows[0].agent_name;

    const newTask =
      (req.body && typeof req.body.task === 'string' && req.body.task.trim().length > 0)
        ? req.body.task
        : 'Processing Task ' + Date.now();

    const updateQuery =
      'UPDATE agent_status ' +
      "SET status = 'BUSY', current_task = $1, last_heartbeat = CURRENT_TIMESTAMP " +
      'WHERE agent_name = $2 ' +
      'RETURNING agent_name, current_task;';

    const updateResult = await client.query(updateQuery, [newTask, agentName]);

    assignedAgent = updateResult.rows[0];

    await client.query('COMMIT');

    return res.json({
      message: 'Task successfully delegated.',
      agent: assignedAgent,
      source: 'db',
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error during task delegation:', err);
    return res.status(500).json({ error: 'Delegation failed due to server error.' });
  } finally {
    client.release();
  }
});

// 5) API Endpoint: Task Completion (DB-backed, optional)
app.post('/api/complete-task-db', async (req, res) => {
  const body = req.body || {};
  const agentName = body.agentName;

  if (!agentName || typeof agentName !== 'string') {
    return res.status(400).json({ error: 'Agent name is required.' });
  }

  try {
    const query =
      'UPDATE agent_status ' +
      "SET status = 'IDLE', current_task = NULL, last_heartbeat = CURRENT_TIMESTAMP " +
      'WHERE agent_name = $1 ' +
      'RETURNING agent_name, status;';

    const result = await pool.query(query, [agentName]);

    if (result.rowCount === 0) {
      return res.status(404).json({
        message: 'Agent ' + agentName + ' not found or was already IDLE.',
      });
    }

    return res.json({
      message: 'Task completed. Agent ' + agentName + ' is now IDLE.',
      agent: result.rows[0],
      source: 'db',
    });
  } catch (err) {
    console.error('Error during task completion:', err);
    return res.status(500).json({ error: 'Task completion failed due to server error.' });
  }
});

/**
 * Phase 11 override: stubbed task endpoints (avoid Postgres dependency)
 * These are the endpoints the current dashboard JS calls.
 */
app.post('/api/delegate-task', async (req, res) => {
  try {
    const body = req.body || {};
    const title =
      (typeof body.task === "string" && body.task.trim()) ? body.task.trim()
      : (typeof body.title === "string" && body.title.trim()) ? body.title.trim()
      : "";
    const agent = (typeof body.agent === "string" && body.agent.trim()) ? body.agent.trim() : "cade";
    const notes = (typeof body.notes === "string") ? body.notes : "";

    if (!title) return res.status(400).json({ error: "task/title is required", source: "db-tasks" });

    // DB-first: insert into tasks table if DB is up
    if (await __dbOk()) {
      await __ensureTasksSchema();
      const r = await pool.query(
        "insert into tasks (title, agent, notes, status) values ($1,$2,$3,$4) returning id, title, agent, notes, status, created_at::text, updated_at::text",
        [title, agent, notes, "delegated"]
      );
      console.log("[task] DELEGATED " + JSON.stringify({ id: r.rows[0].id, status: r.rows[0].status, agent: r.rows[0].agent, title: r.rows[0].title }));
      return res.json({ task: r.rows[0], source: "db-tasks" });
    }

    // Fallback: mem-next2 behavior (keeps old dashboard compatibility)
    const task = { id: Date.now(), title, agent, notes, status: "delegated", createdAt: __nowIso(), updatedAt: __nowIso() };
    __memStore.tasks.unshift(task);
    __cap(__memStore.tasks, 200);
    return res.json(task);
  } catch (err) {
    console.error("/api/delegate-task failed:", err);
    return res.status(500).json({ error: "delegate failed", source: "db-tasks" });
  }
});

app.post('/api/complete-task', async (req, res) => {
  try {
    const body = req.body || {};
    const raw = body.taskId;
    const taskId = (typeof raw === "number") ? raw : parseInt(String(raw || ""), 10);

    if (!taskId || Number.isNaN(taskId)) {
      return res.status(400).json({ error: "taskId is required", source: "db-tasks" });
    }

    // DB-first: update tasks table if DB is up
    if (await __dbOk()) {
      await __ensureTasksSchema();

      const r = await pool.query(
        "update tasks set status = 'completed', updated_at = now() where id = $1 returning id, title, agent, notes, status, created_at::text, updated_at::text",
        [taskId]
      );

      if (!r.rowCount) {
        return res.status(404).json({ id: taskId, status: "not_found", source: "db-tasks" });
      }
      console.log("[task] COMPLETED " + JSON.stringify({ id: r.rows[0].id, status: r.rows[0].status, agent: r.rows[0].agent, title: r.rows[0].title }));
      return res.json({ task: r.rows[0], source: "db-tasks" });
    }

    // Fallback: mem-next2 behavior (keeps old dashboard compatibility)
    const idx = __memStore.tasks.findIndex((t) => String(t.id) === String(taskId));
    if (idx === -1) return res.json({ id: taskId, status: "not_found", source: "mem-next2" });

    __memStore.tasks[idx].status = "completed";
    return res.json({ id: taskId, status: "completed", source: "mem-next2" });
  } catch (err) {
    console.error("/api/complete-task failed:", err);
    return res.status(500).json({ error: "complete failed", source: "db-tasks" });
  }
});


// Phase 11 – Matilda dashboard chat endpoint (single canonical implementation)
app.post('/api/chat', async (req, res) => {
  try {
    const body = req.body || {};
    const rawMessage = body.message ?? '';
    const rawAgent = body.agent ?? 'matilda';

    const message = String(rawMessage).trim();
    const agent = String(rawAgent).trim() || 'matilda';

    if (!message) return res.status(400).json({ reply: '(empty message)' });

    console.log('[/api/chat] agent=%s message=%s', agent, message);

    let reply;
    if (agent === 'matilda') {
      reply = `Matilda: I see you said, "${message}". I am online here on the dashboard with you.`;
    } else {
      reply = `(${agent}) received: "${message}".`;
    }

    return res.json({ reply });
  } catch (err) {
    console.error('Error in /api/chat:', err);
    return res.status(500).json({ reply: '(error)' });
  }
});


// --- Minimal Observability (Phase 13.3) -------------------------------------
app.get("/health", async (_req, res) => {
  try {
    const dbOk = await __dbOk();
    return res.json({
      ok: true,
      service: "motherboard-systems-hq",
      uptime_s: Math.round(process.uptime()),
      ts: new Date().toISOString(),
      db: { ok: !!dbOk },
      pid: process.pid,
    });
  } catch (e) {
    return res.status(503).json({
      ok: false,
      service: "motherboard-systems-hq",
      uptime_s: Math.round(process.uptime()),
      ts: new Date().toISOString(),
      db: { ok: false },
      error: (e && e.message) ? e.message : "health_check_failed",
    });
  }
});

// --- Next-2: SSE stubs (same-origin) -----------------------------------------
function sseHeaders(res) {
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  if (typeof res.flushHeaders === "function") res.flushHeaders();
}

function sseSend(res, event, data) {
  if (event) res.write("event: " + event + "\n");
  res.write("data: " + JSON.stringify(data) + "\n\n");
}

app.get("/events/ops", (req, res) => {
  sseHeaders(res);
  sseSend(res, null,  { status: "unknown", ts: Date.now(), source: "stub-next2" });
  const t = setInterval(() => sseSend(res, null,  { status: "unknown", ts: Date.now(), source: "stub-next2" }), 5000);
  req.on("close", () => clearInterval(t));
});

app.get("/events/reflections", (req, res) => {
  sseHeaders(res);
  sseSend(res, null,  { message: "Reflections stream stub (next-2).", ts: Date.now(), source: "stub-next2" });
  const t = setInterval(() => sseSend(res, null,  { message: "Reflections stream stub (next-2).", ts: Date.now(), source: "stub-next2" }), 8000);
  req.on("close", () => clearInterval(t));
});

app.get("/events/tasks", async (req, res) => {
  const id = Math.random().toString(16).slice(2,8);
  console.log("[events/tasks] CONNECT", id, new Date().toISOString(), req.headers["user-agent"]);

  // SSE keepalive: prevents idle intermediaries/timeouts from dropping the stream.
  // Sends a comment frame (ignored by clients) every 15s.
  const __mbhq_tasks_hb = setInterval(() => {
    try { res.write(":keepalive\\n\\n"); } catch {}
  }, 15000);

  req.on("close", () => {
    try { clearInterval(__mbhq_tasks_hb); } catch {}
  });
  req.on("aborted", () => console.log("[events/tasks] ABORTED", id, new Date().toISOString()));
  req.on("close",   () => console.log("[events/tasks] REQ_CLOSE", id, new Date().toISOString()));
  res.on("close",   () => console.log("[events/tasks] RES_CLOSE", id, new Date().toISOString()));
  res.on("finish",  () => console.log("[events/tasks] FINISH", id, new Date().toISOString()));
  res.on("error",   (e) => console.log("[events/tasks] RES_ERROR", id, e && e.message));
  if (res.socket) {
    res.socket.on("error", (e) => console.log("[events/tasks] SOCK_ERROR", id, e && e.message));
    res.socket.setTimeout(0);
    res.socket.setNoDelay(true);
    res.socket.setKeepAlive(true);
  }
  sseHeaders(res);


  // SSE kick: help browsers/proxies flush the stream immediately
  res.write(": ready\n");
  res.write(":" + " ".repeat(2048) + "\n\n");

  // Only emit when task list changes (ignore ts)
  let lastKey = "";

  async function snapshot() {
    const useDb = await __dbOk();
    const tasks = useDb ? await __listTasks(50) : __memStore.tasks;
    return { tasks, source: useDb ? "db-tasks" : "mem-next2" };
  }

  async function emit() {
    try {
      const snap = await snapshot();
      // Key excludes ts so unchanged lists do not re-emit
      const key = JSON.stringify({ tasks: snap.tasks, source: snap.source });
      if (key !== lastKey) {
        lastKey = key;
        sseSend(res, null, { ...snap, ts: Date.now() });
      }
    } catch (_e) {
      const snap = { tasks: __memStore.tasks, source: "mem-next2", error: "stream_error" };
      const key = JSON.stringify({ tasks: snap.tasks, source: snap.source, error: snap.error });
      if (key !== lastKey) {
        lastKey = key;
        sseSend(res, null, { ...snap, ts: Date.now() });
      }
    }
  }

  await emit();
  const t = setInterval(emit, 3000);
  const hb = setInterval(() => {
    try { res.write(": hb\n\n"); } catch (_e) {}
  }, 3000);
  req.on("close", () => {
    console.log("[events/tasks] CLOSE", new Date().toISOString());
    clearInterval(t);
    clearInterval(hb);
  });
});

app.get("/events/logs", (req, res) => {
  sseHeaders(res);
  sseSend(res, null,  { logs: [], ts: Date.now(), source: "stub-next2" });
  const t = setInterval(() => sseSend(res, null,  { logs: [], ts: Date.now(), source: "stub-next2" }), 7000);
  req.on("close", () => clearInterval(t));
});
// ---------------------------------------------------------------------------
  // --- Compatibility: /tasks (raw array for older loaders) ------------------
  app.get("/tasks", async (_req, res) => {
    try {
      if (!(await __dbOk())) return res.json(__memStore.tasks);
      const tasks = await __listTasks(50);
      return res.json(tasks);
    } catch (err) {
      console.error("/tasks failed:", err);
      return res.json(__memStore.tasks);
    }
  });


// --- API: delegation + completion + chat (Phase 12 restore) ---------
app.post("/api/delegate-task", async (req, res) => {
  try {
    const body = req.body || {};
    const agent = String(body.agent || "cade");
    const title = String(body.title || "").trim();
    const notes = String(body.notes || "");
    if (!title) return res.status(400).json({ ok: false, error: "title_required" });

    const useDb = await __dbOk();
    let task;

    if (useDb) {
      // Expect DB helpers to exist; if not, we fall back to mem below.
      if (typeof __createTask === "function") {
        task = await __createTask({ agent, title, notes });
      } else {
        throw new Error("__createTask_missing");
      }
    } else {
      task = {
        id: String(Date.now()),
        title,
        agent,
        notes,
        status: "delegated",
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };
      __memStore.tasks = [task, ...(__memStore.tasks || [])];
    }

    return res.json({ ok: true, task, source: useDb ? "db" : "mem" });
  } catch (err) {
    // Hard fallback: never block UI on DB helper absence
    const body = req.body || {};
    const agent = String(body.agent || "cade");
    const title = String(body.title || "").trim() || "(untitled)";
    const notes = String(body.notes || "");
    const task = {
      id: String(Date.now()),
      title,
      agent,
      notes,
      status: "delegated",
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      error: String(err && err.message ? err.message : err),
    };
    __memStore.tasks = [task, ...(__memStore.tasks || [])];
    return res.json({ ok: true, task, source: "mem" });
  }
});

app.post("/api/complete-task", async (req, res) => {
  try {
    const body = req.body || {};
    const taskId = String(body.taskId || body.id || "").trim();
    if (!taskId) return res.status(400).json({ ok: false, error: "taskId_required" });

    const useDb = await __dbOk();
    if (useDb) {
      if (typeof __completeTask === "function") {
        const out = await __completeTask(taskId);
        return res.json({ ok: true, id: taskId, status: "completed", result: out, source: "db" });
      }
      // If DB helpers missing, fall back to mem behavior
      throw new Error("__completeTask_missing");
    }

    // mem fallback
    const tasks = __memStore.tasks || [];
    const idx = tasks.findIndex(t => String(t.id) === taskId);
    if (idx >= 0) {
      tasks[idx] = { ...tasks[idx], status: "completed", updated_at: new Date().toISOString() };
    }
    __memStore.tasks = tasks;
    return res.json({ ok: true, id: taskId, status: "completed", source: "mem" });
  } catch (err) {
    return res.status(500).json({ ok: false, error: String(err && err.message ? err.message : err) });
  }
});

// Keep Matilda working even if you are still on a stub phase
app.post("/api/chat", async (_req, res) => {
  return res.json({ ok: true, reply: "(stub) Matilda chat endpoint is live. Wire real backend next.", ts: Date.now(), source: "stub-next2" });
});
// ---------------------------------------------------------------------------

// Fallback route for SPA or index
app.use((req, res, next) => {
  if (req.path && req.path.startsWith('/api/')) return next();
  return res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

const server = app.listen(PORT, HOST, () => {
  console.log('Server running on http://' + HOST + ':' + PORT);
  console.log('Database pool initialized');
});

// Keep connections alive for SSE (avoid ~5s keep-alive defaults)
server.keepAliveTimeout = 120000;
server.headersTimeout = 125000;
server.requestTimeout = 0;
