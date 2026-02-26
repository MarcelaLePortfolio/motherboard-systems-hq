import express from "express";
import { registerApiHealth } from "./server/routes/api-health.mjs";
import { waitForPostgresReady } from "./server/db_wait_ready.mjs";
import { registerOptionalSSE } from "./server/optional-sse.mjs";
import path from "path";
import { fileURLToPath } from "url";
import pg from "pg";
import { ensureTasksTaskIdColumn } from "./server/db_bootstrap_tasks_task_id.mjs";
import { registerOrchestratorStateRoute } from "./server/orchestrator_state_route.mjs";
import { registerPhase19DebugRoutes } from "./server/phase19_debug_routes_dump.mjs";
import { apiTasksRouter } from "./server/routes/api-tasks-postgres.mjs";

// Phase 44 — server HTTP mutation-route enforcement boundary (off/shadow/enforce)
import { createMutationEnforcementMiddleware } from "./server/enforcement/phase44_mutation_enforcer.mjs";

import { attachArtifacts } from "./server/artifacts.mjs";
import { dbDelegateTask, dbCompleteTask } from "./server/tasks-mutations.mjs";
import taskEventsSSE from "./server/routes/task-events-sse.mjs";
import apiTasksMutationsRouter from "./server/routes/api-tasks-mutations.mjs";
import { handleDelegateTaskSpec as phase23HandleDelegateTaskSpec } from "./server/api/tasks-mutations/delegate-taskspec.mjs";
import { registerPhase36RunView } from "./server/routes/phase36_run_view.mjs";
import { getRunsList } from "./server/routes/phase36_run_view.mjs";

import { registerPhase40_6ShadowAuditTaskEvents } from "./server/routes/phase40_6_shadow_audit_task_events.mjs";
import { registerPhase48PolicyProbe } from "./server/routes/phase48_policy_probe.mjs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);


const app = express();



registerApiHealth(app);
// Phase49: enforce gate on real mutation routes (task path)
function phase49PolicyEnforceEnabled() {
  const v = String(process.env.POLICY_ENFORCE_MODE ?? process.env.POLICY_MODE ?? "").trim().toLowerCase();
  // accept common values without binding to any single previous implementation
  return v in {"1":1, "true":1, "yes":1, "on":1, "enforce":1, "enabled":1};
}

app.use((req, res, next) => {
  try {
    if (!phase49PolicyEnforceEnabled()) return next();
    if (req.path === "/api/policy/probe") return next();

    const m = String(req.method || "GET").toUpperCase();
    const isMut = (m === "POST" || m === "PUT" || m === "PATCH" || m === "DELETE");
    if (!isMut) return next();

    // Start narrow: enforce on the real task mutation surface.
    if (req.path.startsWith("/api/tasks")) {
      return res.status(403).json({
        error: "policy.enforce",
        detail: "mutation blocked by enforcement gate (Phase49)",
        path: req.path,
        method: m,
      });
    }

    return next();
  } catch (e) {
    return next(e);
  }
});

// Phase 44 — enforce only at HTTP mutation route boundary
app.use(createMutationEnforcementMiddleware());
// Phase 23: parse JSON early (avoid empty req.body)
app.use(express.json());

// Phase 20: task-events SSE (event-sourced)
app.use(taskEventsSSE);
  
registerOrchestratorStateRoute(app);
registerPhase19DebugRoutes(app);
if (process.env.PHASE19_DEBUG === "1") {
  console.log("[phase19] env", {
    PHASE18_ENABLE_ORCHESTRATION: process.env.PHASE18_ENABLE_ORCHESTRATION,
    PHASE19_ENABLE_ORCH_STATE: process.env.PHASE19_ENABLE_ORCH_STATE,
  });
}
app.use(express.text({ type: "*/*", limit: "64kb" }));
app.post("/api/phase16-beacon", (req, res) => {
  try { console.log("[BEACON]", req.body); } catch (e) { console.log("[BEACON] <unreadable>"); }
  res.status(204).end();
});

app.use((req,res,next)=>{ console.log("[HTTP] " + req.method + " " + req.url); next(); });

// ===== PHASE16_SSE_HUB (OPS + Reflections) =====

// --- Phase 16.9: framework-agnostic JSON responder (Express or plain Node) ---
function _phase16SendJson(res, code, obj) {
  try {
    if (res && typeof res.status === "function" && typeof res.json === "function") {
      return res.status(code).json(obj);
    }
    // Node http.ServerResponse fallback
    if (res && typeof res.setHeader === "function" && typeof res.end === "function") {
      res.statusCode = code;
      res.setHeader("Content-Type", "application/json; charset=utf-8");
      res.end(JSON.stringify(obj));
      return;
    }
  } catch (_) {}
  // Last resort: do nothing
}
// --- /Phase 16.9 ---
  function _phase16CreateSSEHub(name) {
    const hub = {
      name,
      clients: new Set(),
      last: null,
      nextId: 1,
      broadcast(payload, eventName) {
        const id = String(this.nextId++);
        const data = typeof payload === "string" ? payload : JSON.stringify(payload);
        const event = eventName || "message";
        const frame = `id: ${id}\nevent: ${event}\ndata: ${data}\n\n`;
        this.last = { id, data, event };
        for (const res of this.clients) {
          try { res.write(frame); } catch (_) {}
        }
        return id;
      },
      attach(res) {
        this.clients.add(res);
        res.on("close", () => this.clients.delete(res));
        try { res.write(`: connected ${name}\n\n`); } catch (_) {}
        if (this.last) {
          try {
            res.write(`id: ${this.last.id}\nevent: ${this.last.event}\ndata: ${this.last.data}\n\n`);
          } catch (_) {}
        }
      },
    };
    return hub;
  }

  if (!globalThis.__SSE) globalThis.__SSE = {};
  if (!globalThis.__SSE.ops) globalThis.__SSE.ops = _phase16CreateSSEHub("ops");
  if (!globalThis.__SSE.reflections) globalThis.__SSE.reflections = _phase16CreateSSEHub("reflections");

  if (!globalThis.__OPS_STATE) {
    globalThis.__OPS_STATE = { status: "unknown", lastHeartbeatAt: null, agents: {} };
  }
  // ==============================================

  // Phase 36.2: run_view-backed run observability (must not depend on optional SSE)
  registerPhase36RunView(app);

  registerPhase48PolicyProbe(app);

// Phase 16: optional dashboard SSE endpoints (OPS + Reflections)
try {
  registerOptionalSSE(app);
  console.log("[SSE] /events/ops + /events/reflections registered");
} catch (e) {
  console.warn("[SSE] Failed to register optional SSE:", e && e.message ? e.message : e);
}

// Serve static assets from ./public (required for /css/* and /js/* on /dashboard)
app.use(express.static(path.join(__dirname, "public")));
app.use("/css", express.static(path.join(__dirname, "public", "css")));
app.use("/js", express.static(path.join(__dirname, "public", "js")));
app.use("/img", express.static(path.join(__dirname, "public", "img")));
// Phase 23: TaskSpec adapter -> create task + emit task_events
app.post("/api/tasks-mutations/delegate-taskspec", async (req, res) => phase23HandleDelegateTaskSpec(req, res, { db: pool, dbDelegateTask }));

// Phase 23: TaskSpec adapter -> create task + emit task_events


// Phase 23: TaskSpec adapter -> existing delegate

app.use("/api/tasks", apiTasksRouter);
app.use("/api/tasks-mutations", apiTasksMutationsRouter);

// --- Phase 16.7: dev-only emit endpoints (local debug) ---
app.post("/api/dev/emit-reflection", (req, res) => {
  try {
    const body = req.body || {};
    const item = {
      ts: body.ts != null ? body.ts : Date.now(),
      title: body.title != null ? String(body.title) : "dev",
      msg: body.msg != null ? String(body.msg) : "dev reflection",
      kind: body.kind != null ? String(body.kind) : "dev",
    };

    // keep snapshot cache in sync for /events/reflections snapshot-on-connect
    if (!globalThis.__REFLECTIONS_STATE || typeof globalThis.__REFLECTIONS_STATE !== "object") {
      globalThis.__REFLECTIONS_STATE = { items: [], lastAt: null };
    }
    if (!Array.isArray(globalThis.__REFLECTIONS_STATE.items)) globalThis.__REFLECTIONS_STATE.items = [];
    globalThis.__REFLECTIONS_STATE.items = [item, ...globalThis.__REFLECTIONS_STATE.items].slice(0, 50);
    globalThis.__REFLECTIONS_STATE.lastAt = item.ts;

    // Prefer the optional-sse broadcaster globals if present
    if (typeof globalThis.__broadcastReflections === "function") {
      try { globalThis.__broadcastReflections({ item }); } catch (_) {}
      return _phase16SendJson(res, 200, { ok: true, via: "globalThis.__broadcastReflections", item });
    }

    // Or use the Phase16 SSE hub if present
    if (globalThis.__SSE && globalThis.__SSE.reflections && typeof globalThis.__SSE.reflections.broadcast === "function") {
      globalThis.__SSE.reflections.broadcast("reflections.add", { item });
      return _phase16SendJson(res, 200, { ok: true, via: "globalThis.__SSE.reflections.broadcast", item });
    }

    // Legacy/alt broadcaster shape
    if (globalThis.__SSE_BROADCAST && typeof globalThis.__SSE_BROADCAST.reflections === "function") {
      globalThis.__SSE_BROADCAST.reflections({ event: "reflections.add", data: { item } });
      return _phase16SendJson(res, 200, { ok: true, via: "globalThis.__SSE_BROADCAST.reflections", item });
    }

    return _phase16SendJson(res, 202, { ok: true, via: "none", note: "No reflections broadcaster found; SSE-only build", item });
  } catch (e) {
    return _phase16SendJson(res, 500, { ok: false, error: String(e) });
  }
});


app.post("/api/dev/emit-ops", (req, res) => {
  try {
    const body = req.body || {};
    const state = {
      status: body.status != null ? String(body.status) : "unknown",
      lastHeartbeatAt: body.lastHeartbeatAt != null ? body.lastHeartbeatAt : Date.now(),
      agents: body.agents != null ? body.agents : {},
    };

    globalThis.__OPS_STATE = state;

    if (typeof globalThis.__broadcastOps === "function") {
      try { globalThis.__broadcastOps(state); } catch (_) {}
      return _phase16SendJson(res, 200, { ok: true, via: "globalThis.__broadcastOps", state });
    }

    if (globalThis.__SSE && globalThis.__SSE.ops && typeof globalThis.__SSE.ops.broadcast === "function") {
      globalThis.__SSE.ops.broadcast(state, "ops.state");
      return _phase16SendJson(res, 200, { ok: true, via: "globalThis.__SSE.ops.broadcast", state });
    }

    if (globalThis.__SSE_BROADCAST && typeof globalThis.__SSE_BROADCAST.ops === "function") {
      globalThis.__SSE_BROADCAST.ops({ event: "ops.state", data: state });
      return _phase16SendJson(res, 200, { ok: true, via: "globalThis.__SSE_BROADCAST.ops", state });
    }

    return _phase16SendJson(res, 202, { ok: true, via: "none", note: "No ops broadcaster found; SSE-only build", state });
  } catch (e) {
    return _phase16SendJson(res, 500, { ok: false, error: String(e) });
  }
});

// --- /Phase 16.7 ---


const { emitArtifact } = attachArtifacts(app);

const PORT = process.env.PORT || 3000;

const { Pool } = pg;
const DB_URL_RAW = process.env.POSTGRES_URL || process.env.DATABASE_URL || "";

// Normalize DB_URL: pg treats empty password as null -> SCRAM error ("password must be a string").
// If URL has user but empty password, fill from PGPASSWORD (or default "postgres").
function _normalizeDbUrl(raw) {
  try {
    if (!raw) return "";
    if (!/^postgres(ql)?:\/\//i.test(raw)) return raw;
    const u = new URL(raw);
    const hasUser = (u.username || "") !== "";
    const hasPw = (u.password || "") !== "";
    if (hasUser && !hasPw) {
      u.password = String(process.env.PGPASSWORD || "postgres");
      console.warn("[db] DB_URL had empty password; filled from PGPASSWORD/default");
    }
    return u.toString();
  } catch (_) {
    return raw;
  }
}

const DB_URL = _normalizeDbUrl(DB_URL_RAW);

const pool = DB_URL
  ? new Pool({ connectionString: DB_URL })
  : new Pool({
      host: process.env.PGHOST || "127.0.0.1",
      port: Number(process.env.PGPORT || 5432),
      user: process.env.PGUSER || "postgres",
      password: process.env.PGPASSWORD || "postgres",
      database: process.env.PGDATABASE || "postgres",
    });


try {
  const o = pool?.options || {};
  const safe = {
    mode: (DB_URL ? "url" : "params"),
    DB_URL_present: Boolean(DB_URL),
    host: o.host || null,
    port: o.port || null,
    user: o.user || null,
    database: o.database || null,
    password_type: typeof o.password,
    password_len: (o.password == null ? null : String(o.password).length),
    has_password: (o.password != null),
  };
  console.log("[db] effective pool config", safe);
} catch (e) {
  console.log("[db] effective pool config <unavailable>", e?.message || String(e));
}
await waitForPostgresReady(pool, { timeoutMs: 60_000 });
await ensureTasksTaskIdColumn(pool);
console.log("Database pool initialized");
  globalThis.__DB_POOL = pool;
  console.log("[phase25] __DB_POOL set", { has: !!globalThis.__DB_POOL, type: (globalThis.__DB_POOL && globalThis.__DB_POOL.constructor && globalThis.__DB_POOL.constructor.name) });

  if (typeof app !== "undefined" && app && app.locals) app.locals.pool = pool;
let lastOpsHeartbeat = Date.now();

// ---- Static dashboard assets ----
app.use("/public", express.static(path.join(__dirname, "public")));
app.get("/bundle.js", (req, res) => res.sendFile(path.join(__dirname, "public", "bundle.js")));

app.get("/api/runs", getRunsList);
app.get("/bundle.js.map", (req, res) => res.sendFile(path.join(__dirname, "public", "bundle.js.map")));
app.get("/dashboard", (req, res) => res.sendFile(path.join(__dirname, "public", "dashboard.html")));
app.get("/", (req, res) => res.redirect("/dashboard"));

// ---- Tasks API ----
app.get("/api/tasks", async (req, res) => {
  try {
    const r = await pool.query(
      `select id::text, title, agent, status, notes, source, trace_id, error, meta, created_at, updated_at
       from tasks
       order by id::int desc`
    );
    res.json({ tasks: r.rows, source: "db-tasks" });
  } catch (e) {
    res.status(500).json({ ok: false, error: String(e) });
  }
});

// ---- Phase 15: real task mutation endpoints (DB-backed) ----
app.post("/api/delegate-task", async (req, res) => {
  try {
    const row = await dbDelegateTask(pool, req.body || {});
    const payload = { ok: true, action: "delegate", task: row };

    emitArtifact({
      type: "task_result",
      source: "cade",
      taskId: row.id,
      payload,
    });

    res.json(payload);
  } catch (e) {
    res.status(500).json({ ok: false, error: String(e) });
  }
});

app.post("/api/complete-task", async (req, res) => {
  try {
    const row = await dbCompleteTask(pool, req.body || {});
    const payload = { ok: true, action: "complete", task: row };

    emitArtifact({
      type: "task_result",
      source: "cade",
      taskId: row.id,
      payload,
    });

    res.json(payload);
  } catch (e) {
    res.status(500).json({ ok: false, error: String(e) });
  }
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
         order by id::int desc`
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

  // Poll for changes (lightweight) – periodic snapshots without UI blinking.
  let lastHash = "";
  const poll = setInterval(async () => {
    if (closed) return;
    try {
      const r = await pool.query(
        `select id::text, title, agent, status, notes, source, trace_id, error, meta, created_at, updated_at
         from tasks
         order by id::int desc`
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

  // Phase 15: build artifact on startup (wire Project Visual Output to real build metadata)
  emitArtifact({
    type: "build_output",
    source: "dashboard",
    payload: {
      status: "boot",
      git_sha: process.env.GIT_SHA || null,
      build_time: process.env.BUILD_TIME || null,
      node: process.version,
      port: PORT,
    },
  });
});


  // ===== PHASE16_OPS_SIGNAL_INGEST =====

  // ===== PHASE16_OPS_STATE_SNAPSHOT_BROADCAST_HELPER =====
  function _phase16BroadcastOpsStateSnapshot(reason) {
    try {
      const st = _phase16GetOpsState();
      const msg = { type: "ops.state", ts: Date.now(), reason: reason || null, payload: st };
      globalThis.__SSE.ops.broadcast(msg, "ops.state");
      return msg;
    } catch (_) {
      return null;
    }
  }
  // ======================================================

  if (!globalThis.__SSE) globalThis.__SSE = {};
  if (!globalThis.__SSE.ops) globalThis.__SSE.ops = { clients: new Set(), nextId: 1, last: null,
    broadcast(payload, eventName) {
      const id = String(this.nextId++);
      const data = typeof payload === "string" ? payload : JSON.stringify(payload);
      const event = eventName || "message";
      const frame = `id: ${id}\nevent: ${event}\ndata: ${data}\n\n`;
      this.last = { id, data, event };
      for (const res of this.clients) { try { res.write(frame); } catch (_) {} }
      return id;
    },
    attach(res) {
      this.clients.add(res);
      res.on("close", () => this.clients.delete(res));
      try { res.write(`: connected ops\n\n`); } catch (_) {}
      if (this.last) { try { res.write(`id: ${this.last.id}\nevent: ${this.last.event}\ndata: ${this.last.data}\n\n`); } catch (_) {} }
    },
  };

  if (!globalThis.__OPS_STATE) globalThis.__OPS_STATE = { status: "unknown", lastHeartbeatAt: null, agents: {} };

  function _phase16SSEHeaders(res) {
    res.status(200);
    res.setHeader("Content-Type", "text/event-stream; charset=utf-8");
    res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    res.setHeader("Connection", "keep-alive");
    res.setHeader("X-Accel-Buffering", "no");
    if (res.flushHeaders) res.flushHeaders();
  }

  // (re)register /events/ops if missing
  if (typeof app.get === "function") {
    // best-effort: only add if route not already present via marker above
  }

  app.get("/events/ops", (req, res) => {
    // PHASE16_OPS_CONNECT_PRIMER
    // Ensure the client receives bytes immediately (prevents empty-body reads)
    try { if (typeof res.flushHeaders === "function") res.flushHeaders(); } catch (_) {}
    try { res.write(": ops-sse-connected\n\n"); } catch (_) {}
    _phase16SSEHeaders(res);
    globalThis.__SSE.ops.attach(res);
  });

  function _phase16Now() { return Date.now(); }
  function _phase16BroadcastOps(type, payload) {
    const msg = { type, ts: _phase16Now(), payload };
    globalThis.__SSE.ops.broadcast(msg, type);
    return msg;
  }

  app.post("/api/ops/heartbeat", (req, res) => {
    const body = (req && req.body) || {};
    const source = String(body.source || body.agent || body.from || "unknown");
    const ts = _phase16Now();
    globalThis.__OPS_STATE.status = "live";
    globalThis.__OPS_STATE.lastHeartbeatAt = ts;
    _phase16BroadcastOps("ops.heartbeat", { source, at: ts, meta: body.meta || body });
    res.json({ ok: true, status: globalThis.__OPS_STATE.status, at: ts });
  });

  app.post("/api/ops/agent-status", (req, res) => {
    const body = (req && req.body) || {};
    const agent = String(body.agent || body.name || "unknown");
    const state = String(body.state || body.status || "unknown");
    const ts = _phase16Now();
    globalThis.__OPS_STATE.status = "live";
    globalThis.__OPS_STATE.agents[agent] = { state, at: ts, meta: body.meta || body };
    _phase16BroadcastOps("ops.agent_status", { agent, state, at: ts, meta: body.meta || body });
    res.json({ ok: true, agent, state, at: ts });
  });

  app.get("/api/ops/state", (req, res) => {
    res.json({ ok: true, state: globalThis.__OPS_STATE });
  });
  // ====================================


  // ===== PHASE16_REFLECTIONS_SIGNAL_API =====
  function _phase16BroadcastReflection(type, payload) {
    const msg = { type, ts: Date.now(), payload };
    if (globalThis.__SSE && globalThis.__SSE.reflections && globalThis.__SSE.reflections.broadcast) {
      globalThis.__SSE.reflections.broadcast(msg, type);
    }
    return msg;
  }

  app.post("/api/reflections/signal", (req, res) => {
    const body = (req && req.body) || {};
    const type = String(body.type || "reflections.signal");
    const payload = body.payload || body;
    _phase16BroadcastReflection(type, payload);
    res.json({ ok: true });
  });
  // =========================================


/* ===========================
 * Phase 18: Orchestration Tick
 * ===========================
 * Guarded behind: PHASE18_ENABLE_ORCHESTRATION=1
 * In-memory only; minimal cadence tick.
 */
if (process.env.PHASE18_ENABLE_ORCHESTRATION === "1") {
  import("./server/orchestrator/phase18_orchestration.mjs")
    .then((m) => {
      m.startPhase18OrchestrationRuntime({
        intervalMs: Number(process.env.PHASE18_TICK_MS || 1000),
        log: (msg) => console.log(msg),
      });
    })
    .catch((e) => {
      console.error("[phase18] failed to start orchestration runtime:", e);
    });
}

registerPhase40_6ShadowAuditTaskEvents(app, { db: __DB_POOL });
