import { updateTaskStatus, deleteCompletedTask, setAgentStatus } from "../../db/task-db";

export async function cadeCommandRouter(command: string, task?: any) {
  if (command === "execute" && task) {
    await handleTask(task);
    return { status: "ok", message: "Executed task" };
  }
  return { status: "error", message: "Unknown command" };
}

export async function handleTask(task: any) {
  const { uuid, type, content, agent } = task;
  console.log(`🧠 Cade received task:`, task);

  setAgentStatus(agent, "busy"); // 👷 Mark agent as busy

  // ✨ Simulate task execution
  if (type === "say_hello") {
    console.log(`🗣️ Cade says: ${content}`);
  } else {
    console.log(`⚠️ Unknown task type: ${type}`);
  }

  updateTaskStatus(uuid, "completed"); // ✅ Mark as completed
  deleteCompletedTask(uuid);           // 🧹 Auto-delete completed task

  // ✅ Restore agent to idle with slight delay
  setTimeout(() => setAgentStatus(agent, "idle"), 100);
}
