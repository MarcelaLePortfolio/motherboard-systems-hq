/* eslint-disable import/no-commonjs */
import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import { exec } from "child_process";
import fs from "fs";
import pg from "pg";
import { apiTasksRouter } from "./server/routes/api-tasks-postgres.mjs";
import taskEventsSseRouter from "./server/routes/task-events-sse.mjs";
import operatorGuidanceRouter from "./server/routes/operator-guidance.mjs";
import { createRequire } from "module";

const require = createRequire(import.meta.url);
const { enforceRetryContract } = require("./server/retry_contract.js");
const { routeRetryExecution } = require("./server/retry_execution_router.js");

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
app.use(taskEventsSseRouter);
app.use(operatorGuidanceRouter({ pool }));

const LOG_DIR = path.join(__dirname, "ui/dashboard");
const LOG_FILE = path.join(LOG_DIR, "ticker-events.log");

if (!fs.existsSync(LOG_DIR)) fs.mkdirSync(LOG_DIR, { recursive: true });
if (!fs.existsSync(LOG_FILE)) fs.writeFileSync(LOG_FILE, "");

/**
 * PHASE 580 — REAL TASK PIPELINE + RETRY ROUTING WIRING
 */
app.post("/api/delegate-task", enforceRetryContract, async (req, res) => {
  const body = req.body?.kind === "retry"
    ? routeRetryExecution(req.body || {})
    : (req.body || {});

  const payload = {
    ...(body.payload && typeof body.payload === "object" ? body.payload : {}),
    ...(body.meta && typeof body.meta === "object" ? body.meta : {}),
    execution_mode: body.execution_mode ?? null,
    cache_policy: body.cache_policy ?? null,
    memory_scope: body.memory_scope ?? null
  };

  try {
    const forward = await fetch("http://localhost:3000/api/tasks/create", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        title: body.title || body.task || "Delegated task",
        kind: body.kind || "delegation",
        payload,
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
      Atlas: { status: "offline" },
      Cade: { status: "offline" },
      Effie: { status: "offline" },
    };

    if (!err) {
      try {
        const list = JSON.parse(stdout);
        list.forEach((proc) => {
          const online = proc.pm2_env.status === "online";
          if (proc.name.includes("matilda")) statusMap.Matilda.status = online ? "online" : "offline";
          if (proc.name.includes("atlas")) statusMap.Atlas.status = online ? "online" : "offline";
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

    const names = ["Matilda", "Atlas", "Cade", "Effie"];

    if (!err) {
      try {
        const list = JSON.parse(stdout);
        names.forEach((name) => {
          const proc = list.find((p) => p.name.toLowerCase().includes(name.toLowerCase()));
          agents.push({ name, status: proc?.pm2_env?.status || "offline" });
        });
      } catch {
        names.forEach((name) => agents.push({ name, status: "unknown" }));
      }
    } else {
      names.forEach((name) => agents.push({ name, status: "offline" }));
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


// PHASE703 ADVISORY CHAT ROUTE — deterministic, non-executing, no task/worker/DB coupling
async function generateMatildaAdvisoryReply(input) {

  const promptLines = [
    "You are Matilda, an advisory-only system interface for the Motherboard Systems dashboard.",
    "You may explain, interpret, summarize, and reason conversationally.",
    "You must not claim you executed anything.",
    "You must not say you changed files, triggered workers, restarted services, deployed code, modified databases, gathered live status, checked systems, ran diagnostics, or performed infrastructure actions.",
    "Keep the response natural, helpful, and concise.",
    "If the user asks for a systems check, explain that you can interpret dashboard information they provide or surfaced state included in the chat context.",
    "Do not imply direct dashboard viewing, active monitoring, live status gathering, or diagnostics unless read-only context has actually been provided.",
    "Avoid phrases such as checking now, seeing now, taking a look, or give me a moment.",
    "",
    "User message:",
    String(input || '')
  ];

  const prompt = promptLines.join('\n');

  const controller = new AbortController();

  const timeout = setTimeout(() => controller.abort(), 20000);

  try {

    const response = await fetch("http://host.docker.internal:11434/api/generate", {

      method: "POST",

      headers: { "Content-Type": "application/json" },

      signal: controller.signal,

      body: JSON.stringify({

        model: "gemma3:4b",

        prompt,

        stream: false

      })

    });

    if (!response.ok) {

      return null;

    }

    const data = await response.json();

    const reply = String(data?.response || "").trim();

    if (!reply) {

      return null;

    }

    return reply;

  } catch (err) {

    console.error("Matilda Ollama advisory generation failed:", err?.message || err);

    return null;

  } finally {

    clearTimeout(timeout);

  }

}

// 6. API Endpoint: Advisory Chat (Phase 706)

app.post("/api/chat", async (req, res) => {

  try {

    const body = req.body || {};

    const message = typeof body.message === "string" ? body.message : "";

    const input = typeof body.input === "string" ? body.input : message;

    const normalized = String(input || "").trim();

    let reply;

    if (!normalized) {

      reply = "Advisory response only: no message received. I can explain runtime state, execution boundaries, guidance signals, and dashboard behavior. No execution performed.";

    } else if (/execute|run task|deploy|restart|shutdown|delete|modify database|trigger worker/i.test(normalized)) {

      reply = "I cannot execute actions from this chat surface. I cannot trigger workers, deploy code, restart services, delete data, or modify infrastructure. Execution pathways remain isolated from chat.";

    } else {

      reply = await generateMatildaAdvisoryReply(normalized);

      if (!reply) {

        reply = "Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.";

      }

    }

    res.json({

      reply,

      meta: {

        mode: "advisory-ollama-with-deterministic-safety",

        execution: false,

        systemCoupling: false

      }

    });

  } catch (err) {

    console.error("Error in /api/chat:", err);

    res.status(500).json({

      reply: "Advisory response only: chat route error. No execution performed.",

      meta: {

        mode: "advisory-ollama-with-deterministic-safety",

        execution: false,

        systemCoupling: false

      }

    });

  }

});

app.use(express.static(path.join(__dirname, "ui/dashboard")));
app.use(express.static(path.join(__dirname, "public")));

app.listen(PORT, () => {
  console.log(`✅ Dashboard live on port ${PORT}`);
  console.log("Execution Inspector now wired to real task pipeline");
});


// PHASE615 CONTROLLED SYSTEM SCHEDULER (DISABLED BY DEFAULT)
const SYSTEM_SCHEDULER_ENABLED = String(process.env.SYSTEM_SCHEDULER_ENABLED || "").toLowerCase() === "true";
const SYSTEM_SCHEDULER_INTERVAL_MS = Number(process.env.SYSTEM_SCHEDULER_INTERVAL_MS || 60000);

let phase615SchedulerInFlight = false;

if (SYSTEM_SCHEDULER_ENABLED) {
  console.log("[phase615] scheduler started", {
    interval_ms: SYSTEM_SCHEDULER_INTERVAL_MS
  });

  setInterval(async () => {
    if (phase615SchedulerInFlight) {
      console.log("[phase615] skipped (guard active)");
      return;
    }

    phase615SchedulerInFlight = true;

    try {
      await fetch("http://localhost:3000/api/delegate-task", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          kind: "system-check",
          title: "System Scheduler Task",
          payload: {
            source: "system",
            intent: "scheduled-check"
          }
        })
      });

      console.log("[phase615] task dispatched");
    } catch (err) {
      console.error("[phase615] scheduler failed:", err.message);
    } finally {
      phase615SchedulerInFlight = false;
    }
  }, SYSTEM_SCHEDULER_INTERVAL_MS);
} else {
  console.log("[phase615] scheduler disabled");
}

