import { isAgentBusy } from "../../db/task-db";
import { fetchAllQueuedTasks, setAgentStatus, storeTaskResult } from "../../db/task-db";
import { logToOpsStream } from "../../utils/logger";

const agent = "cade";
const tasks = fetchAllQueuedTasks(agent);
console.log("🧾 Found queued tasks:", tasks);

if (tasks.length > 0) {
  const task = tasks[0];
  setAgentStatus(agent, "busy");
  storeTaskResult(task.uuid, "✅ Dispatched by Matilda");
  logToOpsStream(`🚀 Dispatched queued task ${task.uuid} to ${agent}`);
  console.log(`✅ Task ${task.uuid} dispatched`);
} else {
  console.log("📭 No queued tasks to dispatch.");
}
