import fs from 'fs';
import path from 'path';
import readline from 'readline';

// Define project root and memory paths
const PROJECT_ROOT = path.join(__dirname, '../../../..', 'Motherboard_Systems_HQ');
const MEMORY_DIR = path.join(PROJECT_ROOT, 'memory');
const TASK_FILE = path.join(MEMORY_DIR, 'chained_tasks.json');
const LOG_FILE = path.join(MEMORY_DIR, 'matilda_orchestration.log');

// Ensure directories and files exist
if (!fs.existsSync(MEMORY_DIR)) fs.mkdirSync(MEMORY_DIR, { recursive: true });
if (!fs.existsSync(TASK_FILE)) fs.writeFileSync(TASK_FILE, '[]');
if (!fs.existsSync(LOG_FILE)) fs.writeFileSync(LOG_FILE, '');

// Utility functions
function loadTasks() {
  return JSON.parse(fs.readFileSync(TASK_FILE, 'utf-8'));
}
function saveTasks(tasks) {
  fs.writeFileSync(TASK_FILE, JSON.stringify(tasks, null, 2));
}
function logAction(action: string, payload: any = {}) {
  const entry = { time: new Date().toISOString(), action, payload };
  fs.appendFileSync(LOG_FILE, JSON.stringify(entry) + '\n');
}

// Task functions
function addTask(description: string) {
  const tasks = loadTasks();
  const task = { id: Date.now(), description, status: 'pending', createdAt: new Date().toISOString() };
  tasks.push(task);
  saveTasks(tasks);
  logAction('task-added', { task });
  console.log(`📝 Task added: ${description}`);
}

function showTasks() {
  const tasks = loadTasks();
  console.log('📋 Current Tasks:', tasks);
}

function runNextTask() {
  const tasks = loadTasks();
  const next = tasks.find(t => t.status === 'pending');
  if (!next) {
    console.log('✅ All tasks completed!');
    return;
  }
  console.log(`🚀 Running task: ${next.description}`);
  next.status = 'done';
  next.updatedAt = new Date().toISOString();
  saveTasks(tasks);
  logAction('task-completed', { task: next });
  console.log(`🏁 Completed task: ${next.description}`);
}

// Autonomous loop
function autoRunLoop() {
  setInterval(() => {
    const tasks = loadTasks();
    const next = tasks.find(t => t.status === 'pending');
    if (next) {
      console.log(`🤖 Auto-running task: ${next.description}`);
      runNextTask();
    }
  }, 30000);
}

// CLI
console.log('🤖 Matilda Orchestration Mode Ready!');
console.log('Commands: add-task <desc>, show-tasks, run-next, exit');

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
rl.on('line', (input) => {
  const [cmd, ...rest] = input.trim().split(' ');
  const arg = rest.join(' ');

  switch (cmd) {
    case 'add-task':
      addTask(arg);
      break;
    case 'show-tasks':
      showTasks();
      break;
    case 'run-next':
      runNextTask();
      break;
    case 'exit':
      console.log('👋 Shutting down Matilda...');
      rl.close();
      process.exit(0);
      break;
    default:
      console.log(`Matilda (echo): ${input}`);
      logAction('echo', { input });
  }
});

// Start autonomous loop
autoRunLoop();
