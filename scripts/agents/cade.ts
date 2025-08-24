import { storeTaskResult, setAgentStatus } from "../../db/task-db";

// <0001cade> Task executor for Cade
export async function cadeCommandRouter(command: string, task?: any) {
  if (command === "execute" && task) {
    await handleTask(task);
    return { status: "ok", message: "Executed task" };
  }
  return { status: "error", message: "Unknown command" };
}

export async function handleTask(task: any) {
  console.log(`🧠 Cade received task:`, task);
  setAgentStatus("cade", "busy");

  try {
    if (task.type === "test") {
      const parsed = typeof task.content === "string" ? JSON.parse(task.content) : task.content;
      console.log(`📢 Message: ${parsed.message}`);
      
      storeTaskResult(task.uuid, {
        message: "✅ Handled by Cade!",
        originalMessage: parsed.message,
      });
    } else {
      console.log("❌ Unknown task type:", task.type);
      storeTaskResult(task.uuid, { error: "Unknown task type" });
    }
  } finally {
    setAgentStatus("cade", "idle");
  }
}
