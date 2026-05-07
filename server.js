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
function pickMatildaPhrase(options = []) {

  if (!Array.isArray(options) || options.length === 0) {

    return '';

  }

  return options[Math.floor(Math.random() * options.length)];

}

function buildSafeStatusGuidance() {

  const openings = [

    'The surfaced context is limited, read-only, and non-authoritative.',

    'The currently surfaced advisory context is limited and read-only.',

    'Only limited advisory context is currently available from the chat surface.',

    'The advisory layer currently exposes only compact, non-authoritative context.'

  ];

  const certainty = [

    'The guidance endpoint is available, but this does not confirm overall subsystem health.',

    'The available context does not verify whether all subsystems are healthy.',

    'This compact context is insufficient for authoritative system health confirmation.',

    'Additional verification would be required before making broad health claims.'

  ];

  const nextSteps = [

    'Reviewing the dashboard for alerts, queue state, or subsystem indicators would be the safest next verification step.',

    'A safe next step would be checking visible dashboard indicators or recent alerts.',

    'The dashboard would provide more reliable operational detail than the compact advisory context alone.',

    'Inspecting surfaced runtime indicators would help establish a more authoritative status assessment.'

  ];

  return [

    pickMatildaPhrase(openings),

    pickMatildaPhrase(certainty),

    pickMatildaPhrase(nextSteps)

  ].join(' ');

}

function buildSafePriorityGuidance() {

  const openings = [

    'The surfaced context is limited, read-only, and non-authoritative.',

    'Only compact advisory context is currently available.',

    'The current advisory context is intentionally limited and non-authoritative.'

  ];

  const reasoning = [

    'Because the available context does not confirm subsystem health, prioritization confidence is limited.',

    'The compact advisory context does not establish enough evidence to confidently prioritize subsystem work.',

    'There is not enough surfaced evidence here to safely determine operational priority.'

  ];

  const nextSteps = [

    'Reviewing dashboard alerts, retry queues, worker indicators, or recent failures would help determine the safest priority.',

    'A reasonable next step would be checking visible runtime indicators before assigning priority.',

    'Additional surfaced operational detail would be needed before making a confident prioritization recommendation.'

  ];

  return [

    pickMatildaPhrase(openings),

    pickMatildaPhrase(reasoning),

    pickMatildaPhrase(nextSteps)

  ].join(' ');

}

async function generateMatildaAdvisoryReply(input) {

  const compactContext = {
    runtime: {
      dashboard: "online",
      chat: "model-backed advisory mode",
      executionBoundary: "chat cannot execute tasks, mutate data, trigger workers, or change infrastructure"
    },
    guidance: {
      status: "available",
      latestSummary: "Guidance endpoint is available, but this compact context does not prove every subsystem is currently healthy.",
      certainty: "limited-read-only-context"
    },
    limits: {
      readOnly: true,
      execution: false,
      systemCoupling: false
    }
  };

  const promptLines = [
    "You are Matilda, an advisory-only system interface for the Motherboard Systems dashboard.",
    "You may explain, interpret, summarize, and reason conversationally.",
    "You must not claim you executed anything.",
    "You must not say you changed files, triggered workers, restarted services, deployed code, modified databases, gathered live status, checked systems, ran diagnostics, or performed infrastructure actions.",
    "You must not invent metrics, queue lengths, task counts, health states, logs, task outcomes, or runtime facts that are not explicitly present in the provided read-only context or the user message.",

    "Do not convert compact, default, stale, or limited read-only summaries into broad claims that all systems are healthy.",

    "When the user asks for status, never state that all systems are healthy, normal, operational, stable, or fine unless the user explicitly supplied those observations.",

    "For status questions, explicitly describe the context as limited, read-only, and non-authoritative.",

    "Prefer wording such as: the surfaced context is limited, the guidance endpoint is available, or additional verification would be needed for authoritative status confirmation.",

    "Recommend the safest next inspection step instead of overstating certainty.",
    "Keep the response natural, helpful, and concise.",
    "Use the provided read-only context when relevant.",
    "If the user provides dashboard details, logs, error text, task state, worker state, or visible UI indicators, reason from those details and suggest the next safest inspection or recovery step.",
    "If needed information is missing, do not dead-end. State what is known, what is unknown, and what specific dashboard detail or safe inspection would help next.",
    "Do not imply direct dashboard viewing, active monitoring, or live diagnostics beyond the provided context and the user shared observations.",
    "Avoid phrases such as checking now, seeing now, taking a look, or give me a moment.",
    "",
    "Read-only surfaced context:",
    JSON.stringify(compactContext, null, 2),
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



// Phase 707: compact read-only context for Matilda chat

app.get("/api/chat/context", async (req, res) => {

  try {

    const context = {

      runtime: {

        dashboard: "online",

        chat: "model-backed advisory mode",

        executionBoundary: "chat cannot execute tasks, mutate data, trigger workers, or change infrastructure"

      },

      guidance: {

        status: "available",

        latestSummary: "Guidance endpoint is available, but this compact context does not prove every subsystem is currently healthy.",
      certainty: "limited-read-only-context"

      },

      limits: {

        readOnly: true,

        execution: false,

        systemCoupling: false,

        note: "Context is compact and surfaced for interpretation only."

      }

    };

    res.json(context);

  } catch (err) {

    console.error("Error building /api/chat/context:", err);

    res.status(500).json({

      error: "Failed to build chat context",

      readOnly: true,

      execution: false

    });

  }

});

app.post("/api/chat", async (req, res) => {

  try {

    const body = req.body || {};

    const message = typeof body.message === "string" ? body.message : "";

    const input = typeof body.input === "string" ? body.input : message;

    const normalized = String(input || "").trim();

    let reply;

    if (!normalized) {

      reply = 'Advisory response only: no message received. I can explain runtime state, execution boundaries, guidance signals, and dashboard behavior. No execution performed.';

    } else if (/execute|run task|deploy|restart|shutdown|delete|modify database|trigger worker/i.test(normalized)) {

      reply = 'I cannot execute actions from this chat surface. I cannot trigger workers, deploy code, restart services, delete data, or modify infrastructure. Execution pathways remain isolated from chat.';

    } else if (/system status|status|health|healthy|operational/i.test(normalized)) {

      reply = buildSafeStatusGuidance();

    } else if (/prioritize|priority|what should we prioritize|next step/i.test(normalized)) {

      reply = buildSafePriorityGuidance();

    } else {

      reply = await generateMatildaAdvisoryReply(normalized);

      if (!reply) {

        reply = 'Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.';

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

