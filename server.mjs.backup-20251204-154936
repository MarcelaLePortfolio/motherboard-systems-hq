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

// Phase 11 stubbed task endpoints to avoid Postgres dependency
app.post("/api/delegate-task", (req, res) => {
  const { title, agent, notes } = req.body || {};
  const fakeId = Math.floor(Date.now() / 1000);
  res.json({
    id: fakeId,
    title,
    agent,
    notes,
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

app.use(express.json()); // Middleware to parse JSON body for POST requests

// Database Connection Pool
const pool = new Pool({
  user: process.env.POSTGRES_USER || 'postgres',
  host: process.env.DB_HOST || 'postgres', // 'postgres' is the service name in docker-compose
  database: process.env.POSTGRES_DB || 'dashboard_db',
  password: process.env.POSTGRES_PASSWORD || 'password',
  port: 5432,
});

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

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

// 6. API Endpoint: Matilda Chat (NEW)
app.post('/api/chat', async (req, res) => {
  try {
    const body = req.body || {};
    const message = body.message;
    const agent = body.agent;

    if (!message || typeof message !== 'string') {
      return res.status(400).json({ reply: '(no message received)' });
    }

    const agentLabel = agent || 'matilda';
    const reply =
      'Matilda placeholder: I heard "' +
      message +
      '" (agent: ' +
      agentLabel +
      ').';

    res.json({ reply: reply });
  } catch (err) {
    console.error('Error in /api/chat:', err);
    res.status(500).json({ reply: '(error)' });
  }
});

// Fallback route for SPA or index
app.use((req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, HOST, () => {
  console.log('Server running on http://' + HOST + ':' + PORT);
  console.log('Database pool initialized');
});

// Phase 11 override: stubbed task endpoints take precedence over any earlier DB-backed handlers
app.post("/api/delegate-task", (req, res) => {
  const { title, agent, notes } = req.body || {};
  const fakeId = Math.floor(Date.now() / 1000);
  return res.json({
    id: fakeId,
    title,
    agent,
    notes,
    status: "delegated",
    source: "stub-override"
  });
});

app.post("/api/complete-task", (req, res) => {
  const { taskId } = req.body || {};
  return res.json({
    id: taskId ?? null,
    status: "completed",
    source: "stub-override"
  });
});

