import fs from "fs";
import path from "path";
import readline from "readline";

const memoryDir = path.resolve(process.cwd(), "memory");
const tasksFile = path.join(memoryDir, "chained_tasks.json");
const logFile = path.join(memoryDir, "chaining_runtime_log.json");

interface Task {
  id: string;
  description: string;
  status: "pending" | "in-progress" | "done";
  createdAt: string;
  updatedAt: string;
}

function loadTasks(): Task[] {
  try {
    return JSON.parse(fs.readFileSync(tasksFile, "utf-8"));
  } catch {
    return [];
  }
}

function saveTasks(tasks: Task[]) {
  fs.writeFileSync(tasksFile, JSON.stringify(tasks, null, 2));
}

function logAction(action: string, detail: any = {}) {
  const timestamp = new Date().toISOString();
  const logEntry = { timestamp, action, ...detail };

  let logs: any[] = [];
  try {
    logs = JSON.parse(fs.readFileSync(logFile, "utf-8"));
  } catch {}
  logs.push(logEntry);
  fs.writeFileSync(logFile, JSON.stringify(logs, null, 2));
}

function addTask(description: string) {
  const tasks = loadTasks();
  const newTask: Task = {
    id: Date.now().toString(),
    description,
    status: "pending",
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  tasks.push(newTask);
  saveTasks(tasks);
  logAction("task-added", { task: newTask });
  console.log(`✅ Task added: ${description}`);
}

function showTasks() {
  const tasks = loadTasks();
  if (tasks.length === 0) {
    console.log("📭 No tasks in queue.");
    return;
  }
  console.log("📋 Current tasks:");
  tasks.forEach((t) => console.log(`- [${t.status}] ${t.id}: ${t.description}`));
}

function runNextTask() {
  const tasks = loadTasks();
  const next = tasks.find((t) => t.status === "pending");
  if (!next) {
    console.log("🎉 No pending tasks!");
    return;
  }
  next.status = "done";
  next.updatedAt = new Date().toISOString();
  saveTasks(tasks);
  logAction("task-completed", { task: next });
  console.log(`🏁 Completed task: ${next.description}`);
}

// CLI
console.log("🤖 Matilda Orchestration Mode Ready!");
console.log("Commands: add-task <desc>, show-tasks, run-next, exit");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

rl.on("line", (input) => {
  const [cmd, ...rest] = input.trim().split(" ");
  const arg = rest.join(" ");

  switch (cmd) {
    case "add-task":
      addTask(arg);
      break;
    case "show-tasks":
      showTasks();
      break;
    case "run-next":
      runNextTask();
      break;
    case "exit":
      console.log("👋 Shutting down Matilda...");
      rl.close();
      process.exit(0);
      break;
    default:
      console.log(`Matilda (echo): ${input}`);
      logAction("echo", { input });
  }
});
