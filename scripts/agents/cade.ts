import { updateTaskStatus, deleteCompletedTask, setAgentStatus } from "../../db/task-db";

export async function handleTask(task: any) {
  const { uuid, type, content, agent } = task;
  console.log(`🧠 Cade received task:`, task);

  setAgentStatus(agent, "busy"); // 👷 Mark agent as busy

  // ✨ Simulate task execution
  if (type === "say_hello") {
    console.log(`🗣️ Cade says: ${content}`);
  } else if (type === "patch_file" && content?.path && content?.patch) {
    const fs = await import("fs");
    const path = await import("path");

    const fullPath = path.resolve(content.path);
    const before = fs.readFileSync(fullPath, "utf8");
    const patched = before + content.patch;

    fs.writeFileSync(fullPath, patched, "utf8");

    const diff = [
      `--- Before (${content.path})`,
      before.trim(),
      `+++ After`,
      patched.trim()
    ].join("\n");

    const streamPath = path.resolve("logs/ops-stream.log");
    fs.appendFileSync(streamPath, `[DIFF] ${new Date().toISOString()}\n${diff}\n\n`, "utf8");

    // 💌 Queue Effie follow-up task
    await queueTask({
      agent: "Effie",
      type: "open_file",
      content: { path: content.path },
      triggered_by: uuid
    });

    console.log(`📤 Queued follow-up task for Effie to open: ${content.path}`);
  } else {
    console.log(`⚠️ Unknown task type: ${type}`);
  }

  updateTaskStatus(uuid, "completed"); // ✅ Mark as completed
  deleteCompletedTask(uuid);           // 🧹 Auto-delete completed task

  // ✅ Restore agent to idle with slight delay
  setTimeout(() => setAgentStatus(agent, "idle"), 100);
}
export async function cadeCommandRouter(command: string, task?: any) {
  if (command === "execute" && task) {
    await handleTask(task);
    return { status: "ok", message: "Executed task" };
  }
  return { status: "error", message: "Unknown command" };
}
