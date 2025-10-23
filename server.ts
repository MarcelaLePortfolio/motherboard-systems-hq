import path from "path";
import { logsRouter } from "./routes/logs.ts";
import Database from "better-sqlite3";
import path from "path";
const dbCheckPath = path.resolve(process.cwd(), "motherboard.sqlite");
try {
  const dbCheck = new Database(dbCheckPath);
  const tables = dbCheck.prepare("SELECT name FROM sqlite_master WHERE type='table'").all();
  console.log("<0001f9e0> Express DB check:", dbCheckPath, tables);
} catch (err) {
  console.error("❌ Express DB check failed:", err);
}

import { tasksRouter } from "./routes/tasks.ts";
import { agentsStatusRouter } from "./routes/agentsStatus.ts";

import { reflectionsRouter } from "./routes/reflections.ts";


import { matilda } from "./scripts/agents_full/matilda.ts";
global.matilda = matilda;
import express from "express";
import eventsAgents from "./routes/eventsAgents";
import { logsRouter } from "./routes/logs.ts";
import { cadeRouter } from "./routes/cade.ts";
import { systemHealth } from "./routes/diagnostics/systemHealth.ts";
import { persistentInsight } from "./routes/diagnostics/persistentInsight.ts";
import { autonomicAdaptation } from "./routes/diagnostics/autonomicAdaptation.ts";
import { introspectiveSim } from "./routes/diagnostics/introspectiveSim.ts";
import { systemChronicle } from "./routes/diagnostics/systemChronicle.ts";
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


// ✅ Mount dynamic routers before static
app.use("/logs", logsRouter);
app.use("/agents", agentsStatusRouter);
app.use("/events/agents", eventsAgents);
console.log("✅ Mounted /agents route");


console.log("✅ Mounted /tasks route");
app.use("/reflections", reflectionsRouter);
console.log("✅ Mounted /reflections route");

  console.log("<0001f9f4> 🧠 tasksRouter type check:", typeof tasksRouter, Object.keys(tasksRouter));

app.use("/tasks", tasksRouter);



import("./routes/reflections.ts").then(({ reflectionsRouter }) => {
  app.use("/reflections", reflectionsRouter);
  console.log("✅ Mounted /reflections route");
}).catch(err => console.error("❌ Failed to mount /reflections:", err));

// ✅ Serve static files
const publicDir = path.join(process.cwd(), "public");
app.use(express.static(publicDir));
app.get("/", (req, res) => {
  const file = path.join(process.cwd(), "public", "dashboard.html");
  console.log("🧭 Serving dashboard from:", file);
  res.sendFile(file);
});



// ✅ Compatibility export for CJS/TSX

//

//

//

//

//

// ----------------------------------------------------------

import http from "http";


import path from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

app.get("/dashboard.html", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "dashboard.html"));
});

const server = http.createServer(app);
const PORT = process.env.PORT || 3101;


app.post("/debug/broadcast", express.json(), async (req, res) => {
  const { event = "log", message = "Test message", source = "debug", agents = [] } = req.body;
  const { broker } = await import("./routes/eventsAgents.js");
  broker.broadcast(event, { source, message, time: new Date().toISOString(), agents });
  res.json({ ok: true, sent: { event, message, source, agents } });
});
server.listen(PORT, () => {
  console.log(`🚀 Express server running at http://localhost:${PORT}`);

  // Wait a tick so the router tree is hot
  setTimeout(() => {
    if (!app._router)
      return console.log("<0001f9f6> ⚠️ app._router still undefined post-listen");
    const layers = app._router.stack || [];
    layers.forEach(l => dive(l, 0, ""));
  }, 1000);
});
