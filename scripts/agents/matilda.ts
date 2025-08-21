import { isAgentBusy } from "../../db/task-db";
import { isAgentBusy } from "../../db/task-db";
import { getAgentStatus } from "../../db/task-db";
import { getAgentStatus } from "../../db/task-db";
import crypto from "crypto";
import {
  insertTaskToDb,
  fetchLatestCompletedTask,
  storeTaskResult,
  fetchTaskStatus,
  isAgentBusy,
  setAgentStatus
} from "../../db/task-db";
import { logToOpsStream } from "../../utils/logger";

export async function matildaCommandRouter(command: string, args: any = {}) {
  switch (command) {
    case "test-insert": {
      const uuid = crypto.randomUUID?.() || Math.random().toString(36).substring(2);
      const task = {
        uuid,
        agent: "matilda",
        type: "test",
        content: JSON.stringify({ message: "Hello from test-insert" }),
        status: "pending",
        ts: Date.now()
      };
      insertTaskToDb(task);
      logToOpsStream(`🧾 Matilda inserted test task ${uuid}`);
      return { status: "success", message: "✅ Task inserted into DB", uuid };
    }

    case "get-latest-result": {
      const { agent = "matilda", type = "test" } = args;
      const result = fetchLatestCompletedTask(agent, type);
      return result
        ? { status: "success", result }
        : { status: "empty", message: "No result found" };
    }

    case "handle-task-result": {
      const { uuid, result } = args;
      storeTaskResult(uuid, result);
      logToOpsStream(`🧾 Matilda stored result for task ${uuid}`);
      return { status: "ok", message: `✅ Stored result for ${uuid}` };
    }

    case "get-task-status": {
      const { uuid } = args;
      const status = fetchTaskStatus(uuid);
      return status
        ? { status: "success", taskStatus: status }
        : { status: "not_found", message: "Task not found" };
    }

    case "queue-task": {
      const { agent, type, content } = args;
      const uuid = crypto.randomUUID?.() || Math.random().toString(36).substring(2);
      const task = {
        uuid,
        agent,
        type,
        content: JSON.stringify(content),
        status: isAgentBusy(agent) ? "queued" : "pending",
        ts: Date.now()
      };
      insertTaskToDb(task);
      logToOpsStream(`�� Matilda ${task.status === "queued" ? "queued" : "dispatched"} task ${uuid} to ${agent}`);
      return { status: "ok", uuid, queued: task.status === "queued" };
    }

    default:
      return { status: "error", message: "Unknown command" };
  }
}

