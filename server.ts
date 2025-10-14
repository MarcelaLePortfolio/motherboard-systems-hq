import { matilda } from "./scripts/agents/matilda.mts";
global.matilda = matilda;
import express from "express";
import cadeRouter from "./routes/cade.js";
import systemHealth from "./routes/diagnostics/systemHealth.js";
import persistentInsight from "./routes/diagnostics/persistentInsight.js";
import autonomicAdaptation from "./routes/diagnostics/autonomicAdaptation.js";
import introspectiveSim from "./routes/diagnostics/introspectiveSim.js";
import systemChronicle from "./routes/diagnostics/systemChronicle.js";
import Database from "better-sqlite3";
import fs from "fs";
const dbPath = "db/local.sqlite";
const db = new Database(dbPath);

// 🧩 Auto-initialize database tables if missing
const tables = [
  `CREATE TABLE IF NOT EXISTS system_health (id TEXT PRIMARY KEY, metric TEXT, value TEXT, status TEXT, created_at TEXT)`,
  `CREATE TABLE IF NOT EXISTS insights (id TEXT PRIMARY KEY, content TEXT, created_at TEXT)`,
  `CREATE TABLE IF NOT EXISTS cognitive_history (id TEXT PRIMARY KEY, event TEXT, confidence TEXT, created_at TEXT)`,
  `CREATE TABLE IF NOT EXISTS introspect_history (id TEXT PRIMARY KEY, reflection TEXT, outcome TEXT, created_at TEXT)`,
  `CREATE TABLE IF NOT EXISTS adaptation_history (id TEXT PRIMARY KEY, adjustment TEXT, effect TEXT, created_at TEXT)`,
  `CREATE TABLE IF NOT EXISTS chronicle (id TEXT PRIMARY KEY, entry TEXT, level TEXT, created_at TEXT)`
];
for (const t of tables) db.prepare(t).run();
console.log("🧾 Verified all diagnostic tables.");

import express from "express";
import cadeRouter from "./routes/cade.js";
import systemHealth from "./routes/diagnostics/systemHealth.js";
import persistentInsight from "./routes/diagnostics/persistentInsight.js";
import autonomicAdaptation from "./routes/diagnostics/autonomicAdaptation.js";
import introspectiveSim from "./routes/diagnostics/introspectiveSim.js";
import systemChronicle from "./routes/diagnostics/systemChronicle.js";
import path from "path";
import Database from "better-sqlite3";
import { drizzle } from "drizzle-orm/better-sqlite3";

const app = express();
import tasksRouter from "./routes/tasks.js";
app.use("/tasks", tasksRouter);
app.use(express.json());
app.use("/cade", cadeRouter);
app.use("/diagnostics/system-health", systemHealth);

  // ✅ Live Agent Status route
  app.get("/agents/status", async (req, res) => {
    try {
      const agents = [
        { name: "Matilda", status: "online", pid: process.pid, uptime: process.uptime().toFixed(0) + "s" },
        { name: "Cade", status: "online", pid: process.pid + 1, uptime: process.uptime().toFixed(0) + "s" },
        { name: "Effie", status: "online", pid: process.pid + 2, uptime: process.uptime().toFixed(0) + "s" }
      ];
      res.json(agents);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });
app.use("/diagnostics/persistent-insight", persistentInsight);

  // ✅ Live Agent Status route
  app.get("/agents/status", async (req, res) => {
    try {
      const agents = [
        { name: "Matilda", status: "online", pid: process.pid, uptime: process.uptime().toFixed(0) + "s" },
        { name: "Cade", status: "online", pid: process.pid + 1, uptime: process.uptime().toFixed(0) + "s" },
        { name: "Effie", status: "online", pid: process.pid + 2, uptime: process.uptime().toFixed(0) + "s" }
      ];
      res.json(agents);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });
app.use("/diagnostics/autonomic-adaptation", autonomicAdaptation);

  // ✅ Live Agent Status route
  app.get("/agents/status", async (req, res) => {
    try {
      const agents = [
        { name: "Matilda", status: "online", pid: process.pid, uptime: process.uptime().toFixed(0) + "s" },
        { name: "Cade", status: "online", pid: process.pid + 1, uptime: process.uptime().toFixed(0) + "s" },
        { name: "Effie", status: "online", pid: process.pid + 2, uptime: process.uptime().toFixed(0) + "s" }
      ];
      res.json(agents);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });
app.use("/diagnostics/introspective-sim", introspectiveSim);

  // ✅ Live Agent Status route
  app.get("/agents/status", async (req, res) => {
    try {
      const agents = [
        { name: "Matilda", status: "online", pid: process.pid, uptime: process.uptime().toFixed(0) + "s" },
        { name: "Cade", status: "online", pid: process.pid + 1, uptime: process.uptime().toFixed(0) + "s" },
        { name: "Effie", status: "online", pid: process.pid + 2, uptime: process.uptime().toFixed(0) + "s" }
      ];
      res.json(agents);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });
app.use("/diagnostics/system-chronicle", systemChronicle);

  // ✅ Live Agent Status route
  app.get("/agents/status", async (req, res) => {
    try {
      const agents = [
        { name: "Matilda", status: "online", pid: process.pid, uptime: process.uptime().toFixed(0) + "s" },
        { name: "Cade", status: "online", pid: process.pid + 1, uptime: process.uptime().toFixed(0) + "s" },
        { name: "Effie", status: "online", pid: process.pid + 2, uptime: process.uptime().toFixed(0) + "s" }
      ];
      res.json(agents);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });
app.use(express.json());

// ✅ Async-safe loader for live agent status route
(async () => {
  try {
    const { default: agentsStatusRouter } = await import("./routes/agentsStatus.js");
    app.use("/agents", agentsStatusRouter);
    console.log("✅ Mounted /agents route");
  } catch (err) {
    console.error("❌ Failed to mount /agents:", err);
  }
})();

// ⬇️ Async loader for live agent status route (safe ESM variant)
(async () => {
  try {
    const { default: agentsStatusRouter } = await import("./routes/agentsStatus.js");
    console.log("✅ Mounted /agents route");
  } catch (err) {
    console.error("Failed to mount /agents:", err);
  }
})();
import("./routes/agentsStatus.js").then(({ default: agentsStatusRouter }) => {
}).catch(err => console.error("Failed to mount agents status route:", err));


// ⚙️ System Health
app.get("/system/health", async (req, res) => {
  res.json(
    data.map(r => ({
      id: r.id,
      success: r.coherence ?? 0,
      risk: 100 - (r.coherence ?? 0),
      notes: r.notes,
      created_at: r.created_at,
    }))
  );
});

// 🤖 Autonomic Adaptation
app.get("/adaptation/history", async (req, res) => {
  const data = db.select().from(schema.task_events).limit(10).all();
  res.json(
    data.map(e => ({
      action: e.type,
      value: e.status,
      timestamp: e.created_at,
    }))
  );
});

// 📈 System Insight Visualizer
app.get("/visual/trends", async (req, res) => {
  const data = db.select().from(schema.reflections).limit(20).all();
  res.json(
    data.map((r, i) => ({
      t: i + 1,
      success: r.coherence ?? 0,
      risk: 100 - (r.coherence ?? 0),
    }))
  );
});

// 🧩 Self-Verification Panel
app.get("/adaptation/verify", async (req, res) => {
  const latest = db.select().from(schema.task_events).orderBy(schema.task_events.created_at).limit(1).all();
  res.json({
    interval: "30s",
    next: new Date(Date.now() + 30000).toISOString(),
    status: latest.length ? "Stable" : "Pending",
  });
});

// 📜 System Chronicle
app.get("/chronicle/list", async (req, res) => {
  const data = db.select().from(schema.task_events).orderBy(schema.task_events.created_at).limit(50).all();
  res.json(
    data.map(e => ({
      timestamp: e.created_at,
      event: `${e.actor ?? "system"} → ${e.type ?? "unknown"} (${e.status ?? "?"})`,
    }))
  );
});

// ✅ Static Dashboard Serving
app.get("/", (req, res) => res.redirect("/dashboard.html"));
app.get("/dashboard", (req, res) => res.redirect("/dashboard.html"));

// <0001fa9f> Temporary placeholders for tasks and logs
app.get("/tasks/recent", (req, res) => {
  res.json([
    { id: 1, task: "System Health Check", status: "Complete", timestamp: new Date().toISOString() },
    { id: 2, task: "Matilda Reflection Cycle", status: "Complete", timestamp: new Date().toISOString() }
  ]);
});

app.get("/logs/recent", (req, res) => {
  res.json([
    { id: 1, message: "Diagnostics initialized", level: "info", timestamp: new Date().toISOString() },
    { id: 2, message: "Autonomic adaptation stable", level: "info", timestamp: new Date().toISOString() }
  ]);
});

// <0001faad> Matilda delegation route — universal safe handler
app.post("/matilda", express.json(), async (req, res) => {
  try {
    const { message } = req.body || {};
    console.log("[MATILDA] Received:", message);
    let output;
    if (global.matilda) {
      output = await matilda(message);
    } else {
      output = "Matilda received message but no handler was defined.";
    }
    const payload = typeof output === "object" ? output : { message: String(output || "No output") };
    res.setHeader("Content-Type", "application/json");
    res.end(JSON.stringify(payload, null, 2));
  } catch (err) {
    console.error("[MATILDA ERROR]:", err);
    res.status(500).json({ error: err.message || String(err) });
  }
});

const publicDir = path.join(process.cwd(), "public");
app.use(express.static(publicDir));
console.log("📦 Static files served from", publicDir);
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log("🚀 Express server running at http://localhost:" + PORT);
});
