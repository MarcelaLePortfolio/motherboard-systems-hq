import express from 'express';
import { fileURLToPath } from 'url';
import path from 'path';
import pg from 'pg';

const { Pool } = pg;

// Environment configuration
const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0'; // Bind to all interfaces for Docker

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

// JSON body parsing for dashboard POSTs
app.use(express.json());

// Database Connection Pool (may be unavailable locally; routes must degrade gracefully)
const pool = new Pool({
  user: process.env.POSTGRES_USER || 'postgres',
  host: process.env.DB_HOST || 'postgres', // docker-compose service name
  database: process.env.POSTGRES_DB || 'dashboard_db',
  password: process.env.POSTGRES_PASSWORD || 'password',
  port: 5432,
});

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// Explicit dashboard route
app.get('/dashboard', (_req, res) => {
  return res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
});

/**
 * Minimal compatibility stubs (Phase 11.x / Next-2)
 * These endpoints are referenced by various dashboard builds/branches.
 */
app.get('/api/status', (_req, res) => {
  const uptimeSeconds = Math.floor(process.uptime());
  return res.json({
    uptimeSeconds,
    health: 'ok',
    lastUpdated: new Date().toISOString(),
    source: 'stub-next2',
  });
});

app.get('/api/tasks', (_req, res) => {
  return res.json({
    tasks: [],
    source: 'stub-next2',
  });
});

app.get('/api/logs', (_req, res) => {
  return res.json({
    logs: [],
    source: 'stub-next2',
  });
});

// 1) API Endpoint: System Metrics
app.get('/api/metrics', async (_req, res) => {
  try {
    const result = await pool.query('SELECT * FROM system_metrics ORDER BY id DESC LIMIT 1');
    if (result.rows.length > 0) return res.json(result.rows[0]);
    return res.status(404).json({ error: 'No metrics found' });
  } catch (err) {
    console.error(err);
    return res.json({ uptime: 0, cpu: 0, memory: 0, disk: 0, source: 'stub-db-down' });
  }
});

// 2) API Endpoint: Task Activity Graph
app.get('/api/activity-graph', async (_req, res) => {
  try {
    const result = await pool.query('SELECT * FROM task_activity ORDER BY timestamp ASC LIMIT 10');
    return res.json(result.rows);
  } catch (err) {
    console.error(err);
    return res.json([]);
  }
});

// 3) API Endpoint: Agent Status Row
app.get('/api/agents', async (_req, res) => {
  try {
    const result = await pool.query(
      'SELECT agent_name, status, current_task, last_heartbeat FROM agent_status ORDER BY status DESC, agent_name ASC'
    );
    return res.json(result.rows);
  } catch (err) {
    console.error(err);
    return res.json([]);
  }
});

// 4) API Endpoint: Task Delegation (DB-backed, optional)
app.post('/api/delegate-task-db', async (req, res) => {
  const client = await pool.connect();
  let assignedAgent = null;

  try {
    await client.query('BEGIN');

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

    await client.query('COMMIT');

    return res.json({
      message: 'Task successfully delegated.',
      agent: assignedAgent,
      source: 'db',
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error during task delegation:', err);
    return res.status(500).json({ error: 'Delegation failed due to server error.' });
  } finally {
    client.release();
  }
});

// 5) API Endpoint: Task Completion (DB-backed, optional)
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

    return res.json({
      message: 'Task completed. Agent ' + agentName + ' is now IDLE.',
      agent: result.rows[0],
      source: 'db',
    });
  } catch (err) {
    console.error('Error during task completion:', err);
    return res.status(500).json({ error: 'Task completion failed due to server error.' });
  }
});

/**
 * Phase 11 override: stubbed task endpoints (avoid Postgres dependency)
 * These are the endpoints the current dashboard JS calls.
 */
app.post('/api/delegate-task', (req, res) => {
  const { title, agent, notes } = req.body || {};
  const fakeId = Math.floor(Date.now() / 1000);
  return res.json({
    id: fakeId,
    title,
    agent,
    notes,
    status: 'delegated',
    source: 'stub-override',
  });
});

app.post('/api/complete-task', (req, res) => {
  const { taskId } = req.body || {};
  return res.json({
    id: taskId ?? null,
    status: 'completed',
    source: 'stub-override',
  });
});

// Phase 11 – Matilda dashboard chat endpoint (single canonical implementation)
app.post('/api/chat', async (req, res) => {
  try {
    const body = req.body || {};
    const rawMessage = body.message ?? '';
    const rawAgent = body.agent ?? 'matilda';

    const message = String(rawMessage).trim();
    const agent = String(rawAgent).trim() || 'matilda';

    if (!message) return res.status(400).json({ reply: '(empty message)' });

    console.log('[/api/chat] agent=%s message=%s', agent, message);

    let reply;
    if (agent === 'matilda') {
      reply = `Matilda: I see you said, "${message}". I am online here on the dashboard with you.`;
    } else {
      reply = `(${agent}) received: "${message}".`;
    }

    return res.json({ reply });
  } catch (err) {
    console.error('Error in /api/chat:', err);
    return res.status(500).json({ reply: '(error)' });
  }
});

// Fallback route for SPA or index
app.use((req, res, next) => {
  if (req.path && req.path.startsWith('/api/')) return next();
  return res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, HOST, () => {
  console.log('Server running on http://' + HOST + ':' + PORT);
  console.log('Database pool initialized');
});
