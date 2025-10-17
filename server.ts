import path from "path";

import { matilda } from "./scripts/agents_full/matilda.ts";
global.matilda = matilda;
import express from "express";
import { logsRouter } from "./routes/logs";
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

import { drizzle } from "drizzle-orm/better-sqlite3";

const app = express();
import tasksRouter from "./routes/tasks.js";
app.use("/tasks", tasksRouter);
app.use(express.json());
app.use("/cade", cadeRouter);
app.use("/diagnostics/system-health", systemHealth);

  // 🪶 Effie Wiring — Local Operations Agent
  app.post("/effie", async (req, res) => {
    const { command, params } = req.body;
    console.log("🪶 Effie received:", command, params);
    try {
      const { effieCommandRouter } = await import("./scripts/agents/effie.ts");
      const result = await effieCommandRouter(command, params);
      res.json(result);
    } catch (err) {
      console.error("Effie error:", err);
      res.status(500).json({ error: err.message });
    }
  });

  // ✅ Effie Local Operations Route
  app.post("/effie", async (req, res) => {
    const { command, params } = req.body;
    console.log("🧠 Effie request:", command, params);
    try {
      const { effieCommandRouter } = await import("./scripts/agents/effie.ts");
      const result = await effieCommandRouter(command, params);
      res.json(result);
    } catch (err) {
      console.error("Effie error:", err);
      res.status(500).json({ error: err.message });
    }
  });

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

  // 🪶 Effie Wiring — Local Operations Agent
  app.post("/effie", async (req, res) => {
    const { command, params } = req.body;
    console.log("🪶 Effie received:", command, params);
    try {
      const { effieCommandRouter } = await import("./scripts/agents/effie.ts");
      const result = await effieCommandRouter(command, params);
      res.json(result);
    } catch (err) {
      console.error("Effie error:", err);
      res.status(500).json({ error: err.message });
    }
  });

  // ✅ Effie Local Operations Route
  app.post("/effie", async (req, res) => {
    const { command, params } = req.body;
    console.log("🧠 Effie request:", command, params);
    try {
      const { effieCommandRouter } = await import("./scripts/agents/effie.ts");
      const result = await effieCommandRouter(command, params);
      res.json(result);
    } catch (err) {
      console.error("Effie error:", err);
      res.status(500).json({ error: err.message });
    }
  });

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

  // 🪶 Effie Wiring — Local Operations Agent
  app.post("/effie", async (req, res) => {
    const { command, params } = req.body;
    console.log("🪶 Effie received:", command, params);
    try {
      const { effieCommandRouter } = await import("./scripts/agents/effie.ts");
      const result = await effieCommandRouter(command, params);
      res.json(result);
    } catch (err) {
      console.error("Effie error:", err);
      res.status(500).json({ error: err.message });
    }
  });

  // ✅ Effie Local Operations Route
  app.post("/effie", async (req, res) => {
    const { command, params } = req.body;
    console.log("🧠 Effie request:", command, params);
    try {
      const { effieCommandRouter } = await import("./scripts/agents/effie.ts");
      const result = await effieCommandRouter(command, params);
      res.json(result);
    } catch (err) {
      console.error("Effie error:", err);
      res.status(500).json({ error: err.message });
    }
  });

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

  // 🪶 Effie Wiring — Local Operations Agent
  app.post("/effie", async (req, res) => {
    const { command, params } = req.body;
    console.log("🪶 Effie received:", command, params);
    try {
      const { effieCommandRouter } = await import("./scripts/agents/effie.ts");
      const result = await effieCommandRouter(command, params);
      res.json(result);
    } catch (err) {
      console.error("Effie error:", err);
      res.status(500).json({ error: err.message });
    }
  });

  // ✅ Effie Local Operations Route
  app.post("/effie", async (req, res) => {
    const { command, params } = req.body;
    console.log("🧠 Effie request:", command, params);
    try {
      const { effieCommandRouter } = await import("./scripts/agents/effie.ts");
      const result = await effieCommandRouter(command, params);
      res.json(result);
    } catch (err) {
      console.error("Effie error:", err);
      res.status(500).json({ error: err.message });
    }
  });

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

  // 🪶 Effie Wiring — Local Operations Agent
  app.post("/effie", async (req, res) => {
    const { command, params } = req.body;
    console.log("🪶 Effie received:", command, params);
    try {
      const { effieCommandRouter } = await import("./scripts/agents/effie.ts");
      const result = await effieCommandRouter(command, params);
      res.json(result);
    } catch (err) {
      console.error("Effie error:", err);
      res.status(500).json({ error: err.message });
    }
  });

  // ✅ Effie Local Operations Route
  app.post("/effie", async (req, res) => {
    const { command, params } = req.body;
    console.log("🧠 Effie request:", command, params);
    try {
      const { effieCommandRouter } = await import("./scripts/agents/effie.ts");
      const result = await effieCommandRouter(command, params);
      res.json(result);
    } catch (err) {
      console.error("Effie error:", err);
      res.status(500).json({ error: err.message });
    }
  });

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

// ⚙️ System Health
app.get("/system/health", async (req, res) => {
  const data = db.select().from(schema.task_events).limit(10).all();
  res.json(data);
});

// ✅ Mount dynamic routers before static
app.use("/logs", logsRouter);
import("./routes/reflections.ts").then(({ reflectionsRouter }) => {
  app.use("/reflections", reflectionsRouter);
  console.log("✅ Mounted /reflections route");
}).catch(err => console.error("❌ Failed to mount /reflections:", err));

// ✅ Serve static files
const publicDir = path.join(process.cwd(), "public");
app.use(express.static(publicDir));
console.log(`📦 Static files served from ${publicDir}`);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Express server running at http://localhost:${PORT}`);
});

export default app;

