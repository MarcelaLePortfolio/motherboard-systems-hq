import fs from "fs";
import path from "path";

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

  const { type, summary } = task || {};
  log(`📬 Received task of type '${type}' — ${summary || "No summary"}`);

  if (type === "delegated_task") {
    log("🧠 Delegating task... (simulated)");
  } else {
    log(`⚠️ Unknown task type: ${type}`);
  }
}

main();
