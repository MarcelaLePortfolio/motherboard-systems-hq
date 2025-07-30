import fs from 'fs';
import readline from 'readline';

const MEMORY_DIR = '/Users/marcela-dev/Desktop/memory';
const TASK_FILE = `${MEMORY_DIR}/chained_tasks.json`;
const LOG_FILE = `${MEMORY_DIR}/matilda_task_log.txt`;

if (!fs.existsSync(MEMORY_DIR)) fs.mkdirSync(MEMORY_DIR, { recursive: true });

interface Task {
  id: number;
  description: string;
  status: 'pending' | 'running' | 'done' | 'error';
  started?: string;
  finished?: string;
  result?: string;
}

let tasks: Task[] = [];
if (fs.existsSync(TASK_FILE)) {
  tasks = JSON.parse(fs.readFileSync(TASK_FILE, 'utf-8'));
}

// Utility: persist tasks
function saveTasks() {
  fs.writeFileSync(TASK_FILE, JSON.stringify(tasks, null, 2));
}

// Utility: log to history
function logHistory(message: string) {
  const line = `[${new Date().toISOString()}] ${message}\n`;
  fs.appendFileSync(LOG_FILE, line);
  console.log(line.trim());
}

// Add a new task
function addTask(description: string) {
  const newTask: Task = { id: Date.now(), description, status: 'pending' };
  tasks.push(newTask);
  saveTasks();
  logHistory(`🆕 Added task: ${description}`);
}

// Show current tasks
function showTasks() {
  console.table(tasks.map(t => ({
    id: t.id,
    desc: t.description,
    status: t.status,
    started: t.started || '',
    finished: t.finished || ''
  })));
}

// Execute next pending task
function runNextTask() {
  const next = tasks.find(t => t.status === 'pending');
  if (!next) {
    console.log('✅ No pending tasks.');
    return;
  }

  next.status = 'running';
  next.started = new Date().toISOString();
  saveTasks();
  logHistory(`🚀 Running task: ${next.description}`);

  try {
    // Simulate execution
    const result = `Matilda executed: ${next.description}`;
    next.result = result;
    next.status = 'done';
    next.finished = new Date().toISOString();
    saveTasks();
    logHistory(`✅ Completed task: ${next.description}`);
  } catch (err) {
    next.status = 'error';
    next.finished = new Date().toISOString();
    next.result = (err as Error).message;
    saveTasks();
    logHistory(`❌ Task failed: ${next.description} - ${(err as Error).message}`);
  }
}

// Auto-run loop every 30s
function autoRunLoop() {
  setInterval(() => {
    const next = tasks.find(t => t.status === 'pending');
    if (next) runNextTask();
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
    case 'add-task': addTask(arg); break;
    case 'show-tasks': showTasks(); break;
    case 'run-next': runNextTask(); break;
    case 'exit':
      console.log('👋 Shutting down Matilda...');
      rl.close();
      process.exit(0);
    default:
      console.log(`Matilda (echo): ${input}`);
  }
});

autoRunLoop();
