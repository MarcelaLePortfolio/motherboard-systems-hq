import { createRequire } from "module";
const require = createRequire(import.meta.url);
const { routeRetryExecution } = require("./server/retry_execution_router.js");
const { enforceRetryContract } = require("./server/retry_contract.js");
import express from 'express';
import { fileURLToPath } from 'url';
import path from 'path';
import pg from 'pg';
import taskEventsSseRouter from "./server/routes/task-events-sse.mjs";
import { apiTasksRouter } from "./server/routes/api-tasks-postgres.mjs";
import operatorGuidanceRouter from "./server/routes/operator-guidance.mjs";

const { Pool } = pg;

// Environment configuration
const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0'; // Bind to all interfaces for Docker

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

app.use(express.json()); // Middleware to parse JSON body for POST requests

// Phase 717 authoritative delegate-task route with narrow retry contract enforcement

app.post("/api/delegate-task", enforceRetryContract, (req, res) => {

  req.body = routeRetryExecution(req.body || {});

  const { title, agent, notes, kind, strategy, meta, execution_mode, cache_policy, memory_scope } = req.body || {};

  const fakeId = Math.floor(Date.now() / 1000);

  res.json({

    id: fakeId,

    title,

    agent,

    notes,

    kind,

    strategy,

    meta,

    execution_mode,

    cache_policy,

    memory_scope,

    status: "delegated",

    source: "stub"

  });

});

app.post("/api/complete-task", (req, res) => {

  const { taskId } = req.body || {};

  res.json({

    id: taskId ?? null,

    status: "completed",

    source: "stub"

  });

});

// Database Connection Pool
const pool = new Pool({
  user: process.env.POSTGRES_USER || 'postgres',
  host: process.env.DB_HOST || 'postgres', // 'postgres' is the service name in docker-compose
  database: process.env.POSTGRES_DB || 'postgres',
  password: process.env.POSTGRES_PASSWORD || 'postgres',
  port: 5432,
});
globalThis.__DB_POOL = pool;

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));
app.use(taskEventsSseRouter);
app.use('/api/tasks', apiTasksRouter);
app.use(operatorGuidanceRouter({ pool }));

// 1. API Endpoint: System Metrics
app.get('/api/metrics', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM system_metrics ORDER BY id DESC LIMIT 1');
    if (result.rows.length > 0) {
      res.json(result.rows[0]);
    } else {
      res.status(404).json({ error: 'No metrics found' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// 2. API Endpoint: Task Activity Graph
app.get('/api/activity-graph', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM task_activity ORDER BY timestamp ASC LIMIT 10');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error fetching activity' });
  }
});

// 3. API Endpoint: Agent Status Row
app.get('/api/agents', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT agent_name, status, current_task, last_heartbeat FROM agent_status ORDER BY status DESC, agent_name ASC'
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error fetching agent status' });
  }
});

// 4. API Endpoint: Task Delegation
app.post('/api/delegate-task-db', async (req, res) => {
  const client = await pool.connect();
  let assignedAgent = null;

  try {
    await client.query('BEGIN'); // Start transaction

    const findAgentQuery =
      'SELECT agent_name FROM agent_status ' +
      "WHERE status = 'IDLE' " +
      'ORDER BY last_heartbeat ASC ' +
      'LIMIT 1 FOR UPDATE';

    const result = await client.query(findAgentQuery);

    if (result.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ message: 'No IDLE agents available.' });
    }

    const agentName = result.rows[0].agent_name;

    const newTask =
      (req.body && typeof req.body.task === 'string' && req.body.task.trim().length > 0)
        ? req.body.task
        : 'Processing Task ' + Date.now();

    const updateQuery =
      'UPDATE agent_status ' +
      "SET status = 'BUSY', current_task = $1, last_heartbeat = CURRENT_TIMESTAMP " +
      'WHERE agent_name = $2 ' +
      'RETURNING agent_name, current_task;';

    const updateResult = await client.query(updateQuery, [newTask, agentName]);

    assignedAgent = updateResult.rows[0];

    await client.query('COMMIT'); // Commit transaction

    res.json({
      message: 'Task successfully delegated.',
      agent: assignedAgent,
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error during task delegation:', err);
    res.status(500).json({ error: 'Delegation failed due to server error.' });
  } finally {
    client.release();
  }
});

// 5. API Endpoint: Task Completion
app.post('/api/complete-task-db', async (req, res) => {
  const body = req.body || {};
  const agentName = body.agentName;

  if (!agentName || typeof agentName !== 'string') {
    return res.status(400).json({ error: 'Agent name is required.' });
  }

  try {
    const query =
      'UPDATE agent_status ' +
      "SET status = 'IDLE', current_task = NULL, last_heartbeat = CURRENT_TIMESTAMP " +
      'WHERE agent_name = $1 ' +
      'RETURNING agent_name, status;';

    const result = await pool.query(query, [agentName]);

    if (result.rowCount === 0) {
      return res.status(404).json({
        message: 'Agent ' + agentName + ' not found or was already IDLE.',
      });
    }

    res.json({
      message: 'Task completed. Agent ' + agentName + ' is now IDLE.',
      agent: result.rows[0],
    });
  } catch (err) {
    console.error('Error during task completion:', err);
    res.status(500).json({ error: 'Task completion failed due to server error.' });
  }
});



// 6. API Endpoint: Advisory Chat (Phase 703)
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

function buildEvidenceBasedGuidance(input = '') {

  const text = String(input || '').trim();

  const evidenceSignals = [

    ['retry', 'retry behavior'],

    ['retries', 'retry behavior'],

    ['queued', 'queued task behavior'],

    ['stuck', 'possible stalled progress'],

    ['failed', 'failure signal'],

    ['error', 'error signal'],

    ['worker', 'worker-related signal'],

    ['log', 'log evidence'],

    ['timeout', 'timeout signal'],

    ['inspector', 'inspector signal'],

    ['alert', 'alert signal']

  ];

  const observed = evidenceSignals

    .filter(([needle]) => text.toLowerCase().includes(needle))

    .map(([, label]) => label);

  const uniqueObserved = [...new Set(observed)];

  const known =

    uniqueObserved.length > 0

      ? `Known from your message: ${uniqueObserved.join(', ')}.`

      : 'Known from your message: you are describing a possible operational symptom, but no specific runtime evidence was provided.';

  const unknown =

    'Unknown: this chat surface has not inspected live logs, queues, workers, or database state.';

  const interpretation =

    uniqueObserved.length > 0

      ? 'Safe interpretation: the supplied evidence may point to a processing, queueing, retry, or worker-path issue, but it is not enough by itself to identify a root cause.'

      : 'Safe interpretation: more concrete evidence is needed before making a useful operational judgment.';

  const nextStep =

    'Safest next inspection: review the relevant dashboard indicator, recent task events, worker logs, or exact error text before choosing a repair path.';

  return [known, interpretation, unknown, nextStep].join(' ');

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
    "You may help the user brainstorm, ideate, scope, plan, compare options, and explain what kinds of projects could be built with the system.",

    "When the user asks what they can build, asks for project ideas, or asks whether a project is possible, answer helpfully with concrete suggestions and safe next steps.",

    "Do not refuse ordinary brainstorming or planning questions merely because chat itself cannot execute actions.",

    "Clearly distinguish between advising/planning from chat and executing work through explicit task/delegation pathways.",
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

    const response = await fetch('http://host.docker.internal:11434/api/generate', {

      method: 'POST',

      headers: { 'Content-Type': 'application/json' },

      signal: controller.signal,

      body: JSON.stringify({

        model: 'gemma3:4b',

        prompt,

        stream: false

      })

    });

    if (!response.ok) {

      return null;

    }

    const data = await response.json();

    const reply = String(data?.response || '').trim();

    if (!reply) {

      return null;

    }

    return reply;

  } catch (err) {

    console.error('Matilda Ollama advisory generation failed:', err?.message || err);

    return null;

  } finally {

    clearTimeout(timeout);

  }

}

// 6. API Endpoint: Advisory Chat (Phase 706)



// Phase 707: compact read-only context for Matilda chat

app.get('/api/chat/context', async (req, res) => {

  try {

    const context = {

      runtime: {

        dashboard: 'online',

        chat: 'model-backed advisory mode',

        executionBoundary: 'chat cannot execute tasks, mutate data, trigger workers, or change infrastructure'

      },

      guidance: {

        status: 'available',

        latestSummary: 'Guidance endpoint is available, but this compact context does not prove every subsystem is currently healthy.',

        certainty: 'limited-read-only-context'

      },

      limits: {

        readOnly: true,

        execution: false,

        systemCoupling: false,

        note: 'Context is compact and surfaced for interpretation only.'

      }

    };

    res.json(context);

  } catch (err) {

    console.error('Error building /api/chat/context:', err);

    res.status(500).json({

      error: 'Failed to build chat context',

      readOnly: true,

      execution: false

    });

  }

});

app.post('/api/chat', async (req, res) => {

  try {

    const body = req.body || {};

    const message = typeof body.message === 'string' ? body.message : '';

    const input = typeof body.input === 'string' ? body.input : message;

    const normalized = String(input || '').trim();

    let reply;

    if (!normalized) {

      reply = 'Advisory response only: no message received. I can explain runtime state, execution boundaries, guidance signals, and dashboard behavior. No execution performed.';

    } else if (/execute|run task|deploy|restart|shutdown|delete|modify database|trigger worker/i.test(normalized)) {

      reply = 'I cannot execute actions from this chat surface. I cannot trigger workers, deploy code, restart services, delete data, or modify infrastructure. Execution pathways remain isolated from chat.';

    } else if (/system status|status|health|healthy|operational/i.test(normalized)) {

      reply = buildSafeStatusGuidance();

    } else if (/prioritize|priority|what should we prioritize|next step/i.test(normalized)) {

      reply = buildSafePriorityGuidance();

    } else if (/retry|retries|queued|stuck|failed|error|worker|log|timeout|inspector|alert/i.test(normalized)) {

      reply = buildEvidenceBasedGuidance(normalized);

    } else {

      reply = await generateMatildaAdvisoryReply(normalized);

      if (!reply) {

        reply = 'Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.';

      }

    }



    res.json({

      reply,

      meta: {

        mode: 'advisory-ollama-with-deterministic-safety',

        execution: false,

        systemCoupling: false

      }

    });

  } catch (err) {

    console.error('Error in /api/chat:', err);

    res.status(500).json({

      reply: 'Advisory response only: chat route error. No execution performed.',

      meta: {

        mode: 'advisory-ollama-with-deterministic-safety',

        execution: false,

        systemCoupling: false

      }

    });

  }

});

app.listen(PORT, HOST, () => {
  console.log('Server running on http://' + HOST + ':' + PORT);
  console.log('Database pool initialized');
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

