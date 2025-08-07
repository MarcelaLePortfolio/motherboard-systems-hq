import fs from "fs";
import path from "path";
import { execSync } from "child_process";

const memoryPath = path.join(__dirname, "memory/matilda_chain_state.json");

function log(message) {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] Matilda: ${message}`);
}

function main() {
  if (!fs.existsSync(memoryPath)) {
    log("⚠️ No task file found.");
    return;
  }

  let task;
  try {
    const raw = fs.readFileSync(memoryPath, "utf8");
    task = JSON.parse(raw);
  } catch (err) {
    log(`❌ Failed to parse task: ${err.message}`);
    return;
  }

  const { type, summary, task: taskName } = task || {};
  log(`📬 Received task of type '${type}' — ${summary || "No summary"}`);

  if (type === "delegated_task") {
    log("<0001f9e0> Delegating task... (simulated)");
  } else if (type === "run_task" && taskName) {
    const taskPath = path.join(__dirname, "matilda_tasks", `${taskName}.mjs`);
    if (fs.existsSync(taskPath)) {
      log(`🚀 Executing subtask: ${taskName}`);
      try {
        execSync(`node ${taskPath}`, { stdio: "inherit" });
      } catch (err) {
        log(`❌ Task execution failed: ${err.message}`);
      }
    } else {
      log(`❌ Task script not found: ${taskPath}`);
    }
  } else {
    log(`⚠️ Unknown task type: ${type}`);
  }
}

main();
