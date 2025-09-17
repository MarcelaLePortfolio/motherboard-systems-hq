import { queueTask } from "../../db/task-db";
import { randomUUID } from "crypto";

const task = {
  uuid: randomUUID(),
  type: "patch",
  content: "console.log('<0001f9ec> Test patch via insert script')",
  path: "scripts/test-agent.ts",
  agent: "cade",
  status: "queued",
  created_at: Date.now(),
  triggered_by: null, // ✅ This avoids the error
};

await queueTask(task);
console.log(`✅ Queued test task: ${task.uuid}`);
