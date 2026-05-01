/* eslint-disable import/no-commonjs */
import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import { exec } from "child_process";
import fs from "fs";
import pg from "pg";
import { apiTasksRouter } from "./server/routes/api-tasks-postgres.mjs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;
app.use(express.json());

const { Pool } = pg;
const pool = new Pool({
  user: process.env.POSTGRES_USER || "postgres",
  host: process.env.DB_HOST || "postgres",
  database: process.env.POSTGRES_DB || "postgres",
  password: process.env.POSTGRES_PASSWORD || "postgres",
  port: 5432,
});
globalThis.__DB_POOL = pool;

app.use("/api/tasks", apiTasksRouter);

const LOG_DIR = path.join(__dirname, "ui/dashboard");
const LOG_FILE = path.join(LOG_DIR, "ticker-events.log");

if (!fs.existsSync(LOG_DIR)) fs.mkdirSync(LOG_DIR, { recursive: true });
if (!fs.existsSync(LOG_FILE)) fs.writeFileSync(LOG_FILE, "");

/**
 * PHASE 572 — REAL TASK PIPELINE WIRING
 */
app.post("/api/delegate-task", async (req, res) => {
  const body = req.body || {};

  try {
    const forward = await fetch("http://localhost:3000/api/tasks/create", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        title: body.title || body.task || "Delegated task",
        kind: body.kind || "delegation",
        payload: body.meta || {},
        source: body.source || "execution-inspector"
      })
    });

    const data = await forward.json();
    return res.json(data);

  } catch (err) {
    console.error("[delegate-task forward error]", err);

    return res.status(500).json({
      error: "delegate-task forwarding failed",
      details: String(err)
    });
  }
});

app.get("/api/agent-status", (req, res) => {
  exec("pm2 jlist", (err, stdout) => {
    const statusMap = {
      Matilda: { status: "offline" },
      Cade: { status: "offline" },
      Effie: { status: "offline" },
    };

    if (!err) {
      try {
        const list = JSON.parse(stdout);
        list.forEach((proc) => {
          const online = proc.pm2_env.status === "online";
          if (proc.name.includes("matilda")) statusMap.Matilda.status = online ? "online" : "offline";
          if (proc.name.includes("cade")) statusMap.Cade.status = online ? "online" : "offline";
          if (proc.name.includes("effie")) statusMap.Effie.status = online ? "online" : "offline";
        });
      } catch {}
    }

    res.json(statusMap);
  });
});

app.get("/api/task-history", (req, res) => {
  try {
    const logs = fs.readFileSync(LOG_FILE, "utf-8").trim().split("\n").filter(Boolean);
    const taskEvents = logs
      .map((line) => {
        let entry;

        try {
          entry = JSON.parse(line);
        } catch {
          const parts = line.split(" | ");
          entry = {
            event: parts[1] || line,
            agent: parts[0] || "unknown",
            timestamp: Math.floor(Date.now() / 1000),
          };
        }

        if (!entry.event || !entry.event.includes("task")) return null;

        return {
          time: new Date(entry.timestamp * 1000).toLocaleTimeString(),
          agent: entry.agent,
          event: entry.event,
        };
      })
      .filter(Boolean)
      .slice(-50);

    res.json(taskEvents);
  } catch {
    res.json([]);
  }
});

app.get("/api/settings", (req, res) => {
  exec("pm2 jlist", (err, stdout) => {
    const agents = [];

    if (!err) {
      try {
        const list = JSON.parse(stdout);
        ["Matilda", "Cade", "Effie"].forEach((name) => {
          const proc = list.find((p) => p.name.toLowerCase().includes(name.toLowerCase()));
          agents.push({ name, status: proc?.pm2_env?.status || "offline" });
        });
      } catch {
        ["Matilda", "Cade", "Effie"].forEach((name) => agents.push({ name, status: "unknown" }));
      }
    } else {
      ["Matilda", "Cade", "Effie"].forEach((name) => agents.push({ name, status: "offline" }));
    }

    res.json({ agents, features: { logRetention: 50, theme: "light" } });
  });
});

app.post("/api/agent-control", (req, res) => {
  const { agent, action } = req.body;
  if (!agent || !action) return res.status(400).json({ success: false, message: "Missing agent or action" });

  let cmd;
  if (action === "start") {
    cmd = `pm2 start scripts/_local/agent-runtime/launch-${agent.toLowerCase()}.ts --interpreter $(which tsx) --name ${agent.toLowerCase()}`;
  } else if (action === "stop") {
    cmd = `pm2 stop ${agent.toLowerCase()}`;
  } else if (action === "restart") {
    cmd = `pm2 restart ${agent.toLowerCase()}`;
  } else {
    return res.status(400).json({ success: false, message: "Unknown action" });
  }

  exec(cmd, (err, stdout, stderr) => {
    if (err) return res.json({ success: false, message: stderr || err.message });
    res.json({ success: true, message: stdout.trim() });
  });
});

app.use(express.static(path.join(__dirname, "ui/dashboard")));
app.use(express.static(path.join(__dirname, "public")));

app.listen(PORT, () => {
  console.log(`✅ Dashboard live on port ${PORT}`);
  console.log("Execution Inspector now wired to real task pipeline");
});
