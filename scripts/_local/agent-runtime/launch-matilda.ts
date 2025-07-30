import fs from 'fs';
import path from 'path';
import readline from 'readline';

// Paths
const PROJECT_ROOT = path.resolve(__dirname, '../../../..');
const MEMORY_DIR = path.join(PROJECT_ROOT, 'memory');
const TASK_FILE = path.join(MEMORY_DIR, 'chained_tasks.json');
const LOG_FILE = path.join(MEMORY_DIR, 'agent_development_tracker.log');

// Types
interface Task {
  description: string;
  status: 'pending' | 'done';
  createdAt: string;
  updatedAt?: string;
}

// Helpers
function loadTasks(): Task[] {
  if (!fs.existsSync(TASK_FILE)) return [];
  try {
    return JSON.parse(fs.readFileSync(TASK_FILE, 'utf-8'));
  } catch {
    return [];
  }
}

function saveTasks(tasks: Task[]) {
  fs.writeFileSync(TASK_FILE, JSON.stringify(tasks, null, 2));
}

function logAction(action: string, data: any) {
  const line = `[${new Date().toISOString()}] ${action}: ${JSON.stringify(data)}\n`;
  fs.appendFileSync(LOG_FILE, line);
}

// Core Functions
function addTask(desc: string) {
  const tasks = loadTasks();
  const task: Task = { description: desc, status: 'pending', createdAt: new Date().toISOString() };
  tasks.push(task);
  saveTasks(tasks);
  logAction('task-added', task);
  console.log(`➕ Task added: ${desc}`);
}

function showTasks() {
  const tasks = loadTasks();
  if (!tasks.length) {
    console.log('📭 No tasks in queue.');
    return;
  }
  console.log('📝 Task Queue:');
  tasks.forEach((t, i) => {
    console.log(`${i + 1}. [${t.status}] ${t.description}`);
  });
}

function runNextTask() {
  const tasks = loadTasks();
  const next = tasks.find(t => t.status === 'pending');
  if (!next) {
    console.log('✅ No pending tasks.');
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
  }, 30000); // every 30 seconds
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
