import fs from 'fs';
import path from 'path';

const taskPath = path.resolve('scripts/_local/memory/effie_task.json');

function readTask(): any {
  try {
    const raw = fs.readFileSync(taskPath, 'utf8');
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function clearTask() {
  try {
    fs.unlinkSync(taskPath);
    console.log('🧹 Effie cleared processed task file');
  } catch {}
}

function processTask(task: any) {
  if (!task?.type) return;

  switch (task.type) {
    case 'log':
      console.log(`📝 Effie received log: "${task.payload}"`);
      break;
    default:
      console.log(`⚠️ Effie received unknown task type: "${task.type}"`);
  }

  clearTask();
}

function poll() {
  if (!fs.existsSync(taskPath)) return;

  const task = readTask();
  if (!task) return;

  processTask(task);
}

setInterval(poll, 3000);
console.log('⚡ Effie Task Processor: Polling every 3 seconds...');
