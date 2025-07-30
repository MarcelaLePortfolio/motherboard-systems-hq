import fs from 'fs';
import path from 'path';
import readline from 'readline';

// ✅ Corrected import path
import '../../src/scripts/agents/matilda.mts';

interface Task {
  id: number;
  description: string;
  status: 'pending' | 'done';
  createdAt: string;
  updatedAt?: string;
}

const TASKS_FILE = path.resolve(__dirname, '../../../memory/matilda_tasks.json');
const LOG_FILE = path.resolve(__dirname, '../../../memory/matilda_log.json');

function loadTasks(): Task[] {
  if (!fs.existsSync(TASKS_FILE)) return [];
  return JSON.parse(fs.readFileSync(TASKS_FILE, 'utf-8'));
}

function saveTasks(tasks: Task[]) {
  fs.writeFileSync(TASKS_FILE, JSON.stringify(tasks, null, 2));
}

function logAction(action: string, payload: any) {
  const logs = fs.existsSync(LOG_FILE) ? JSON.parse(fs.readFileSync(LOG_FILE, 'utf-8')) : [];
  logs.push({ time: new Date().toISOString(), action, payload });
  fs.writeFileSync(LOG_FILE, JSON.stringify(logs, null, 2));
}

function addTask(description: string) {
  const tasks = loadTasks();
  const newTask: Task = { id: tasks.length + 1, description, status: 'pending', createdAt: new Date().toISOString() };
  tasks.push(newTask);
  saveTasks(tasks);
  logAction('add-task', newTask);
  console.log(`✅ Task added: ${description}`);
}

function showTasks() {
  const tasks = loadTasks();
  if (tasks.length === 0) {
    console.log('No tasks found.');
    return;
  }
  console.log('📋 Task List:');
  tasks.forEach((t) => console.log(`${t.id}. [${t.status}] ${t.description}`));
}

function runNextTask() {
  const tasks = loadTasks();
  const next = tasks.find((t) => t.status === 'pending');
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
