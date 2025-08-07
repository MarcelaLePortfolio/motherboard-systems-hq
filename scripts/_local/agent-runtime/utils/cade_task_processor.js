import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';

const STATE_FILE = path.resolve('memory/agent_chain_state.json');

function log(message) {
  console.log(`[${new Date().toISOString()}] ${message}`);
}

function loadTasks() {
  if (!fs.existsSync(STATE_FILE)) return null;
  try {
    const raw = fs.readFileSync(STATE_FILE, 'utf-8');
    return JSON.parse(raw);
  } catch (err) {
    log(`❌ Failed to parse task file: ${err.message}`);
    return null;
  }
}

function runTask(task) {
  if (!task?.type) return false;

  if (task.type === 'generate_file') {
    const fullPath = path.resolve(task.path);
    fs.mkdirSync(path.dirname(fullPath), { recursive: true });
    fs.writeFileSync(fullPath, task.content || '', 'utf-8');
    log(`📄 File generated: ${fullPath}`);
    return true;
  }

  if (task.type === 'run_shell') {
    try {
      execSync(task.command, { stdio: 'inherit' });
      log(`💻 Shell executed: ${task.command}`);
      return true;
    } catch (err) {
      log(`❌ Shell command failed: ${task.command}`);
      return false;
    }
  }

  log(`❓ Unknown task type: ${task.type}`);
  return false;
}

function runAll() {
  const tasks = loadTasks();
  if (!tasks) return;
  const taskArray = Array.isArray(tasks) ? tasks : [tasks];

  for (const task of taskArray) {
    const success = runTask(task);
    if (!success) {
      log('❌ Task chain halted.');
      break;
    }
  }
}

let lastHash = null;

export function startCadeTaskProcessor() {
  runAll(); // Run once on startup

  setInterval(() => {
    const tasks = loadTasks();
    if (!tasks) return;

    const newHash = JSON.stringify(tasks);
    if (newHash !== lastHash) {
      lastHash = newHash;
      log("📡 Change detected — executing task chain");
      runAll();
    }
  }, 3000);
}
