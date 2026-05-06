import express from "express";
import path from 'path';
import { fileURLToPath } from 'url';
import { exec } from 'child_process';
import pg from 'pg';

const { Pool } = pg;
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

app.use(express.json());

const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'postgres',
  port: Number(process.env.POSTGRES_PORT || 5432),
  database: process.env.POSTGRES_DB || 'postgres',
  user: process.env.POSTGRES_USER || 'postgres',
  password: process.env.POSTGRES_PASSWORD || 'postgres'
});

function buildAdvisoryChatReply(input) {
  const normalized = String(input || '').trim();

  if (!normalized) {
    return 'Advisory response only: no message received. I can explain runtime state, execution boundaries, guidance signals, and dashboard behavior. No execution performed.';
  }

  if (/execute|run task|deploy|restart|shutdown|delete|modify database|trigger worker/i.test(normalized)) {
    return 'I cannot execute actions from this chat surface. I cannot trigger workers, deploy code, restart services, delete data, or modify infrastructure. Execution pathways remain isolated from chat.';
  }

  if (/boundary|boundaries|can.*do|cannot|can't|what.*do/i.test(normalized)) {
    return 'I can provide advisory guidance, summarize visible system state, explain dashboard signals, and clarify operational next steps. I cannot execute tasks, mutate the database, trigger workers, or change infrastructure from chat.';
  }

  if (/who are you|what are you|purpose|matilda/i.test(normalized)) {
    return 'I am Matilda, an advisory-only system interface. My purpose is to help interpret runtime state, guidance signals, and operational context while preserving a strict non-executing boundary.';
  }

  return 'Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.';
}

app.get('/api/health', (req, res) => {
  res.json({ ok: true, service: 'motherboard-dashboard' });
});

app.post('/api/chat', async (req, res) => {
  try {
    const body = req.body || {};
    const message = typeof body.message === 'string' ? body.message : '';
    const input = typeof body.input === 'string' ? body.input : message;

    return res.json({
      reply: buildAdvisoryChatReply(input),
      meta: {
        mode: 'advisory-deterministic',
        execution: false,
        systemCoupling: false
      }
    });
  } catch (err) {
    console.error('Error in /api/chat:', err);
    return res.status(500).json({
      reply: 'Advisory response only: chat route error. No execution performed.',
      meta: {
        mode: 'advisory-deterministic',
        execution: false,
        systemCoupling: false
      }
    });
  }
});

app.get('/api/tasks', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM tasks ORDER BY created_at DESC LIMIT 50');
    res.json({ tasks: result.rows });
  } catch (err) {
    console.error('Error fetching tasks:', err);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

app.use(express.static(path.join(__dirname, 'ui/dashboard')));
app.use(express.static(path.join(__dirname, 'public')));

app.listen(PORT, HOST, () => {
  console.log('Server running on http://' + HOST + ':' + PORT);
  console.log('Database pool initialized');
});
