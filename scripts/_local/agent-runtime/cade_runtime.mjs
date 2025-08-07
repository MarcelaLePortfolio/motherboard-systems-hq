import sqlite3 from 'sqlite3';
import { open } from 'sqlite';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const logPath = path.join(__dirname, 'memory', 'cade_runtime.log');
function log(message) {
  const timestamp = new Date().toISOString();
  fs.appendFileSync(logPath, `[${timestamp}] ${message}\n`);
}

const db = await open({
  filename: path.join(__dirname, 'memory', 'agent_brain.db'),
  driver: sqlite3.Database
});

log(`DB ready at ${path.join(__dirname, 'memory', 'agent_brain.db')}`);

const statePath = path.join(__dirname, 'memory', 'agent_chain_state.json');
if (!fs.existsSync(statePath)) {
  log("No task file found for Cade.");
  process.exit(0);
}

let task;
try {
  const rawData = fs.readFileSync(statePath, 'utf8');
  log(`Read task data: ${rawData}`);
  task = JSON.parse(rawData);
} catch (err) {
  log(`❌ Failed to parse task JSON: ${err.message}`);
  process.exit(1);
}

log(`🛠 Cade received task of type: ${task?.type || 'N/A'}`);

try {
  const stmt = await db.prepare("INSERT INTO project_tracker (agent, task_type, task_summary, timestamp) VALUES (?, ?, ?, ?)");
  await stmt.run("cade", task?.type || "unknown", task?.summary || "", Date.now());
  await stmt.finalize();
  log("✅ Task recorded in DB.");
} catch (err) {
  log(`❌ Failed DB write for project_tracker: ${err.message}`);
}
