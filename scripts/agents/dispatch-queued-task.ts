import { getQueuedTasks, setAgentStatus, getAgentStatus, updateTaskStatus, deleteCompletedTask } from "../../db/task-db";
import { cadeCommandRouter } from "./cade";
import Database from "better-sqlite3";

async function dispatchNextTask() {
  const tasks = getQueuedTasks();
  console.log("🧾 Found queued tasks:", tasks);

  if (tasks.length === 0) {
    console.log("📭 No queued tasks to dispatch.");
    return;
  }

  const nextTask = tasks[0];
  const agent = nextTask.agent;

  if (getAgentStatus(agent) !== "idle") {
    console.log(`🛑 ${agent} is busy, task remains queued.`);
    return;
  }

  updateTaskStatus(nextTask.uuid, "pending");

  if (agent === "cade") {
    await cadeCommandRouter("execute", nextTask);
  }

  setTimeout(() => setAgentStatus(agent, "idle"), 100); // ✅ Delay to allow updateTaskStatus to run first
  updateTaskStatus(nextTask.uuid, "completed");

  console.log(`✅ Task ${nextTask.uuid} dispatched`);

  // 🧹 Cleanup completed tasks
  const db = new Database("motherboard.db");
  const cleaned = db.prepare("DELETE FROM tasks WHERE status = 'completed'").run().changes;
  console.log(`🧹 Cleaned up ${cleaned} completed tasks`);
}

dispatchNextTask();
