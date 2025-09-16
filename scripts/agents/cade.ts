import { updateTaskStatus, deleteCompletedTask, setAgentStatus } from "../../db/task-db";

export async function handleTask(task: any) {
  const { uuid, type, content, agent, path: taskPath, insert_after } = task;
  const fs = await import("fs");
  const path = await import("path");

  console.log(`🧠 Cade received task:`, task);
  setAgentStatus(agent, "busy");

  const fullPath = path.resolve(taskPath || "");

  if (!fullPath.startsWith(process.cwd())) {
    console.log("❌ Unsafe file path.");
  } else {
    try {
      if (type === "say_hello") {
        console.log(`🗣️ Cade says: ${content}`);
      } else if (type === "patch") {
        const existing = fs.readFileSync(fullPath, "utf8");
        fs.writeFileSync(fullPath, existing + "\n" + content, "utf8");
        console.log(`✅ Appended patch to "${fullPath}"`);
      } else if (type === "replace") {
        fs.writeFileSync(fullPath, content, "utf8");
        console.log(`✅ Replaced content of "${fullPath}"`);
      } else if (type === "prepend") {
        const existing = fs.readFileSync(fullPath, "utf8");
        fs.writeFileSync(fullPath, content + "\n" + existing, "utf8");
        console.log(`✅ Prepended content to "${fullPath}"`);
      } else if (type === "insert_after") {
        const existing = fs.readFileSync(fullPath, "utf8").split("\n");
        const index = existing.findIndex(line => line.includes(insert_after));
        if (index === -1) {
          console.log("❌ Marker not found for insert_after.");
        } else {
          existing.splice(index + 1, 0, content);
          fs.writeFileSync(fullPath, existing.join("\n"), "utf8");
          console.log(`✅ Inserted after marker in "${fullPath}"`);
        }
      } else {
        console.log(`⚠️ Unknown task type: ${type}`);
      }
    } catch (err) {
      console.log("❌ Task failed:", err.message);
    }
  }

  updateTaskStatus(uuid, "completed");
  deleteCompletedTask(uuid);
  setTimeout(() => setAgentStatus(agent, "idle"), 100);
}
export async function cadeCommandRouter(command: string, task?: any) {
  if (command === "execute" && task) {
    await handleTask(task);
    return { status: "ok", message: "Executed task" };
  }
  return { status: "error", message: "Unknown command" };
}
