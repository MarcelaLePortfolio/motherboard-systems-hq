import path from "path";
import eventsRouter from "./routes/events.js";
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
console.log("🔍 DEBUG — Current working directory:", process.cwd());
console.log("🔍 DEBUG — Expected static path:", path.join(process.cwd(), "public"));

app.use(express.json());
import { router as matildaRouter } from "./routes/matilda.ts";
app.use("/matilda", matildaRouter);
console.log("✅ Mounted /matilda route");

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
import { router as matildaRouter } from "./routes/matilda.ts";
app.use("/matilda", matildaRouter);
console.log("✅ Mounted /matilda route");



// ✅ Mount dynamic routers before static
app.use("/logs", logsRouter);
app.use("/agents", agentsStatusRouter);
console.log("✅ Mounted /agents route");


console.log("✅ Mounted /tasks route");
app.use("/reflections", reflectionsRouter);
console.log("✅ Mounted /reflections route");

  console.log("<0001f9f4> 🧠 tasksRouter type check:", typeof tasksRouter, Object.keys(tasksRouter));

app.use("/tasks", tasksRouter);
app.use("/events", eventsRouter);
import logsRouter from "./routes/logs";
app.use("/logs", logsRouter);



import("./routes/reflections.ts").then(({ reflectionsRouter }) => {
  app.use("/reflections", reflectionsRouter);
  console.log("✅ Mounted /reflections route");
}).catch(err => console.error("❌ Failed to mount /reflections:", err));

// ✅ Serve static files
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
const PORT = process.env.PORT || 3000;


server.listen(PORT, () => {
  console.log(`🚀 Express server running at http://localhost:${PORT}`);

  // Wait a tick so the router tree is hot
  setTimeout(() => {
    if (!app._router)
      return console.log("<0001f9f6> ⚠️ app._router still undefined post-listen");

    const layers = app._router.stack || [];
    console.log("<0001f9f6> 📚 Root stack length:", layers.length);

    function dive(layer, depth = 0, prefix = "") {
      const pad = " ".repeat(depth * 2);
      const keys = Object.keys(layer || {});
      console.log(`${pad}<0001f9f6> 🔸 layer name=${layer.name || "?"} keys=[${keys.join(",")}]`);
      if (layer.route?.path) {
        const methods = Object.keys(layer.route.methods || {})
          .map(m => m.toUpperCase())
          .join(",");
        console.log(`${pad}<0001f9f6> 🗺️ ${methods} ${prefix}${layer.route.path}`);
      }
      if (layer.handle?.stack) {
        layer.handle.stack.forEach(sub => dive(sub, depth + 1, prefix));
      }
    }

    layers.forEach(l => dive(l, 0, ""));
  }, 1000);
});


// --- Restore static dashboard serving ---
import express from "express";
import path from "path";

const staticDir = path.join(process.cwd(), "public");
console.log(`📦 Serving static files from: ${staticDir}`);

  console.log(`🚀 Dashboard available at http://localhost:${PORT}/dashboard.html`);

// --- Final Static Dashboard Fallback ---
import express from "express";
import path from "path";

const staticRoot = path.join(process.cwd(), "public");
app.use("/", express.static(staticRoot));

const fallbackFile = path.join(staticRoot, "dashboard.html");

app.get("/", (_, res) => res.sendFile(fallbackFile));
app.get("/dashboard.html", (_, res) => res.sendFile(fallbackFile));

  console.log(`📦 Static dashboard served from: ${staticRoot}`);
  console.log(`🚀 Access via: http://localhost:${PORT}/dashboard.html`);
console.log("🧭 Reached end of server.ts before static block");
setTimeout(() => {
  import("./scripts/utils/ollamaChat.ts").then(({ ollamaChat }) => {
    ollamaChat("warming up...").then(r =>
      console.log("<0001fa9f> 🌡️ Gemma model pre-warmed (async):", r.slice(0, 60))
    ).catch(err => console.error("<0001fab5> ❌ Gemma warm-up failed:", err));
  });
}, 2000);

