import express from "express";
import path from "path";
import Database from "better-sqlite3";
import { drizzle } from "drizzle-orm/better-sqlite3";
import * as schema from "./db/schema";

const app = express();
app.use(express.json());

// <0001faa0> Phase 15 – Database-linked diagnostic routes
const sqlite = new Database("./db/motherboard.sqlite");
const db = drizzle(sqlite, { schema });

// 🧠 Matilda Insights
app.get("/insight/persist", async (req, res) => {
  const data = db.select().from(schema.insights).all();
  res.json(data);
});

// 🧩 Cognitive Cohesion
app.get("/cognitive/history", async (req, res) => {
  const data = db.select().from(schema.reflections).all();
  res.json(data);
});

// ⚙️ System Health
app.get("/system/health", async (req, res) => {
  const counts = {
    audits: db.select().from(schema.audits).all().length,
    insights: db.select().from(schema.insights).all().length,
    reflections: db.select().from(schema.reflections).all().length,
    lessons: db.select().from(schema.lessons).all().length,
  };
  res.json(counts);
});

// 🔮 Introspective Simulation
app.get("/introspect/history", async (req, res) => {
  const data = db.select().from(schema.reflections).limit(10).all();
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
const publicDir = path.join(process.cwd(), "public");
app.use(express.static(publicDir));
console.log(`📦 Static files served from ${publicDir}`);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Express server running at http://localhost:${PORT}`);
});

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
