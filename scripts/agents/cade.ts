import { updateTaskStatus, deleteCompletedTask, setAgentStatus } from "../../db/task-db";

    switch (task.type) {
      case "patch": {
        if (!task.path || !task.content) {
          result = "❌ Missing fields for patch";
          break;
        }
        const fullPath = path.resolve(task.path);
        if (!fullPath.startsWith(process.cwd())) {
          result = "❌ Unsafe file path.";
          break;
        }
        try {
          const existing = fs.readFileSync(fullPath, "utf8");
          fs.writeFileSync(fullPath, existing + "\n" + task.content, "utf8");
          result = `✅ Appended patch to "${task.path}"`;
        } catch (err) {
          result = "❌ Failed to patch: " + err.message;
        }
        break;
      }
      case "replace": {
        if (!task.path || !task.content) {
          result = "❌ Missing fields for replace";
          break;
        }
        const fullPath = path.resolve(task.path);
        if (!fullPath.startsWith(process.cwd())) {
          result = "❌ Unsafe file path.";
          break;
        }
        try {
          fs.writeFileSync(fullPath, task.content, "utf8");
          result = `✅ Replaced content of "${task.path}"`;
        } catch (err) {
          result = "❌ Failed to replace: " + err.message;
        }
        break;
      }
      case "prepend": {
        if (!task.path || !task.content) {
          result = "❌ Missing fields for prepend";
          break;
        }
        const fullPath = path.resolve(task.path);
        if (!fullPath.startsWith(process.cwd())) {
          result = "❌ Unsafe file path.";
          break;
        }
        try {
          const existing = fs.readFileSync(fullPath, "utf8");
          fs.writeFileSync(fullPath, task.content + "\n" + existing, "utf8");
          result = `✅ Prepended content to "${task.path}"`;
        } catch (err) {
          result = "❌ Failed to prepend: " + err.message;
        }
        break;
      }
      case "insert_after": {
        if (!task.path || !task.insert_after || !task.content) {
          result = "❌ Missing fields for insert_after";
          break;
        }
        const fullPath = path.resolve(task.path);
        if (!fullPath.startsWith(process.cwd())) {
          result = "❌ Unsafe file path.";
          break;
        }
        try {
          const lines = fs.readFileSync(fullPath, "utf8").split("\n");
          const index = lines.findIndex(line => line.includes(task.insert_after));
          if (index === -1) {
            result = "❌ Marker not found for insert_after.";
          } else {
            lines.splice(index + 1, 0, task.content);
            fs.writeFileSync(fullPath, lines.join("\n"), "utf8");
            result = `✅ Inserted after marker in "${task.path}"`;
          }
        } catch (err) {
          result = "❌ Failed to insert_after: " + err.message;
        }
        break;
      }
      case "insert_before": {
        if (!task.path || !task.insert_before || !task.content) {
          result = "❌ Missing fields for insert_before";
          break;
        }
        const fullPath = path.resolve(task.path);
        if (!fullPath.startsWith(process.cwd())) {
          result = "❌ Unsafe file path.";
          break;
        }
        try {
          const lines = fs.readFileSync(fullPath, "utf8").split("\n");
          const index = lines.findIndex(line => line.includes(task.insert_before));
          if (index === -1) {
            result = "❌ Marker not found for insert_before.";
          } else {
            lines.splice(index, 0, task.content);
            fs.writeFileSync(fullPath, lines.join("\n"), "utf8");
            result = `✅ Inserted before marker in "${task.path}"`;
          }
        } catch (err) {
          result = "❌ Failed to insert_before: " + err.message;
        }
        break;
      }
      default: {
        result = `⚠️ Unknown task type: ${task.type}`;
        break;
      }
    }
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
