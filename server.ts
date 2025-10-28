import express from "express";
import cors from "cors";
import path from "path";
import { EventEmitter } from "events";
import { router as matildaRouter } from "./routes/matilda";

export const emitter = new EventEmitter();

const app = express();
app.use(cors());
app.use(express.json());
<<<<<<< HEAD
app.use("/matilda", matildaRouter);
=======
import { router as matildaRouter } from "./routes/matilda.ts";
app.use("/matilda", matildaRouter);
console.log("✅ Mounted /matilda route");

app.use("/cade", cadeRouter);
app.use("/diagnostics/system-health", systemHealth);
>>>>>>> 084506c4 (<0001f9fa> v0.3.36 — Matilda Conversational Mode Restored)

// SSE stream route
app.get("/events", (req, res) => {
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  res.flushHeaders();

  const send = (data: any) => res.write(`data: ${JSON.stringify(data)}\n\n`);
  emitter.on("update", send);

<<<<<<< HEAD
  req.on("close", () => emitter.removeListener("update", send));
=======
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
>>>>>>> 084506c4 (<0001f9fa> v0.3.36 — Matilda Conversational Mode Restored)
});

export function broadcast(message: string) {
  console.log(message);
  emitter.emit("update", { message, timestamp: new Date().toISOString() });
}

const publicDir = path.join(process.cwd(), "public");
app.use(express.static(publicDir));
console.log(`📦 Static files served from ${publicDir}`);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`🚀 Server running at http://localhost:${PORT}`));
