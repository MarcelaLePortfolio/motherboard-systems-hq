import fs from 'fs';
import path from 'path';
import readline from 'readline';

// Canonical memory path
const projectRoot = path.join(process.env.HOME || '', 'Desktop', 'Motherboard_Systems_HQ');
const memoryDir = path.join(projectRoot, 'memory');
const taskFile = path.join(memoryDir, 'chained_tasks.json');

// Ensure memory folder & task file exist
if (!fs.existsSync(memoryDir)) fs.mkdirSync(memoryDir, { recursive: true });
if (!fs.existsSync(taskFile)) fs.writeFileSync(taskFile, '[]', 'utf-8');

interface Task {
  description: string;
  status: 'pending' | 'done';
  createdAt: string;
  updatedAt?: string;
}

function loadTasks(): Task[] {
  try {
    return JSON.parse(fs.readFileSync(taskFile, 'utf-8'));
  } catch {
    fs.writeFileSync(taskFile, '[]', 'utf-8');
    return [];
  }
}

function saveTasks(tasks: Task[]) {
  fs.writeFileSync(taskFile, JSON.stringify(tasks, null, 2), 'utf-8');
}

function addTask(desc: string) {
  const tasks = loadTasks();
  const task: Task = { description: desc, status: 'pending', createdAt: new Date().toISOString() };
  tasks.push(task);
  saveTasks(tasks);
  console.log(`📝 Added task: ${desc}`);
}

function showTasks() {
  const tasks = loadTasks();
  if (!tasks.length) return console.log('�� No tasks in queue.');
  tasks.forEach((t, i) => console.log(`${i + 1}. [${t.status}] ${t.description}`));
}

function runNextTask() {
  const tasks = loadTasks();
  const next = tasks.find(t => t.status === 'pending');
  if (!next) return console.log('✅ All tasks completed!');
  console.log(`🚀 Running task: ${next.description}`);
  next.status = 'done';
  next.updatedAt = new Date().toISOString();
  saveTasks(tasks);
  console.log(`🏁 Completed task: ${next.description}`);
}

// Auto-loop to run pending tasks
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

// CLI interface
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
  }
});

autoRunLoop();
