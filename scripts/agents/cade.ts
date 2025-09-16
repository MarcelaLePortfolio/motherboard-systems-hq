const fs = await import("fs");
export async function handleTask(task: any) {
  const { uuid, type, content, agent, path, insert_before, insert_after } = task;
  let result = "";

  switch (type) {
    case "prepend": {
      const fullPath = pathModule.resolve(path);
      if (!fullPath.startsWith(process.cwd())) { result = "❌ Unsafe file path."; break; }
      try {
        const existing = fs.readFileSync(fullPath, "utf8");
        fs.writeFileSync(fullPath, content + "\n" + existing, "utf8");
        result = `✅ Prepended content to "${path}"`;
      } catch (err: any) { result = "❌ Failed to prepend: " + err.message; }
      break;
    }
    case "replace": {
      const fullPath = pathModule.resolve(path);
      if (!fullPath.startsWith(process.cwd())) { result = "❌ Unsafe file path."; break; }
      try {
        fs.writeFileSync(fullPath, content, "utf8");
        result = `✅ Replaced content in "${path}"`;
      } catch (err: any) { result = "❌ Failed to replace: " + err.message; }
      break;
    }
    case "patch": {
      const fullPath = pathModule.resolve(path);
      if (!fullPath.startsWith(process.cwd())) { result = "❌ Unsafe file path."; break; }
      try {
        const existing = fs.readFileSync(fullPath, "utf8");
        fs.writeFileSync(fullPath, existing + "\n" + content, "utf8");
        result = `✅ Appended patch to "${path}"`;
      } catch (err: any) { result = "❌ Failed to patch: " + err.message; }
      break;
    }
    case "insert_after": {
      const fullPath = pathModule.resolve(path);
      if (!fullPath.startsWith(process.cwd())) { result = "❌ Unsafe file path."; break; }
      try {
        const lines = fs.readFileSync(fullPath, "utf8").split("\n");
        const index = lines.findIndex(line => line.includes(insert_after));
        if (index === -1) { result = "❌ Marker not found for insert_after."; }
        else { lines.splice(index + 1, 0, content); fs.writeFileSync(fullPath, lines.join("\n"), "utf8"); result = `✅ Inserted after marker in "${path}"`; }
      } catch (err: any) { result = "❌ Failed to insert_after: " + err.message; }
      break;
    }
    case "insert_before": {
      const fullPath = pathModule.resolve(path);
      if (!fullPath.startsWith(process.cwd())) { result = "❌ Unsafe file path."; break; }
      try {
        const lines = fs.readFileSync(fullPath, "utf8").split("\n");
        const index = lines.findIndex(line => line.includes(insert_before));
        if (index === -1) { result = "❌ Marker not found for insert_before."; }
        else { lines.splice(index, 0, content); fs.writeFileSync(fullPath, lines.join("\n"), "utf8"); result = `✅ Inserted before marker in "${path}"`; }
      } catch (err: any) { result = "❌ Failed to insert_before: " + err.message; }
      break;
    }
    default: {
      result = `⚠️ Unknown task type: ${type}`;
      break;
    }
  }

  console.log(result);
}
const pathModule = await import("path");
import { updateTaskStatus, deleteCompletedTask, setAgentStatus } from "../../db/task-db";

export async function cadeCommandRouter(command: string, task?: any) {
  if (command === "execute" && task) {
    await handleTask(task);
    return { status: "ok", message: "Executed task" };
  }
  return { status: "error", message: "Unknown command" };
}
