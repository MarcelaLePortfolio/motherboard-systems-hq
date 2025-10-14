import fs from "fs";
import path from "path";

/**
 * pushTask(entry)
 * Records a simple task event to be shown under `/tasks/recent`
 */
export async function pushTask(entry) {
  const file = path.join(process.cwd(), "memory", "tasks.json");
  fs.mkdirSync(path.dirname(file), { recursive: true });

  let tasks = [];
  if (fs.existsSync(file)) {
    try {
      tasks = JSON.parse(fs.readFileSync(file, "utf8"));
    } catch {
      tasks = [];
    }
  }

  const record = {
    id: Date.now(),
    task: entry.task || "(untitled task)",
    status: entry.status || "Complete",
    timestamp: new Date().toISOString()
  };

  tasks.unshift(record);
  if (tasks.length > 50) tasks = tasks.slice(0, 50);
  fs.writeFileSync(file, JSON.stringify(tasks, null, 2), "utf8");

  return record;
}
