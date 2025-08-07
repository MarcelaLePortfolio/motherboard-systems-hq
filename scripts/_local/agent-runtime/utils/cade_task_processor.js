import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';

const statePath = path.resolve('memory/agent_chain_state.json');

function log(message) {
  console.log(`[CADE] ${message}`);
}

function loadTasks() {
  try {
    const raw = fs.readFileSync(statePath, 'utf-8');
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [parsed];
  } catch (err) {
    log('No valid task file or failed to parse JSON.');
    return null;
  }
}

function runTask(task) {
  if (!task?.type) return false;

  if (task.type === 'generate_file') {
    const fullPath = path.resolve(task.path);
    fs.mkdirSync(path.dirname(fullPath), { recursive: true });
    fs.writeFileSync(fullPath, task.content || '', 'utf-8');
    log(`✅ Wrote file to ${task.path}`);
    return true;
  }

  if (task.type === 'run_shell') {
    try {
      execSync(task.command, { stdio: 'inherit' });
      log(`✅ Ran shell command: ${task.command}`);
      return true;
    } catch (err) {
      log(`❌ Shell command failed: ${task.command}`);
      return false;
    }
  }

  log(`❓ Unknown task type: ${task.type}`);
  return false;
}

export function startCadeTaskProcessor() {
  const tasks = loadTasks();
  if (!tasks) return;

  for (const task of tasks) {
    const success = runTask(task);
    if (!success) {
      log('❌ Task chain halted.');
      break;
    }
  }
}

export { startCadeTaskProcessor };
