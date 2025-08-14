/* eslint-disable import/no-commonjs */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { handleTask } from "./handlers/handleTask";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const memoryPath = path.join(__dirname, "memory/agent_chain_state.json");

function log(msg) {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${msg}`);
}

function readTask() {
  if (!fs.existsSync(memoryPath)) {
    log("❌ No task file found.");
    return null;
  }
  try {
    const rawData = fs.readFileSync(memoryPath, "utf8");
    log(`Read task data: ${rawData}`);
    return JSON.parse(rawData);
  } catch (err) {
    log(`❌ Failed to parse task JSON: ${err.message}`);
    return null;
  }
}

async function main() {
  const task = readTask();
  if (!task) return;

  log(`🛠 Cade received task of type: ${task?.type || "N/A"}`);
  await handleTask(task);
}

main();
