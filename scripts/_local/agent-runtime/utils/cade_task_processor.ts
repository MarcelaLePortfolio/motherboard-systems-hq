import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function log(message: string) {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${message}`);
}

function handleTask(task: any) {
  if (!task || !task.type) {
    log(`❌ Invalid task format.`);
    return;
  }

  log(`🛠️ Cade received task of type: ${task.type}`);

  switch (task.type) {
    case 'generate_file':
      if (!task.path || !task.content) {
        log(`❌ Missing 'path' or 'content' in task.`);
        return;
      }
      const fullPath = path.resolve(__dirname, '../../../', task.path);
      fs.mkdirSync(path.dirname(fullPath), { recursive: true });
      fs.writeFileSync(fullPath, task.content);
      log(`✅ File written to ${fullPath}`);
      break;

    default:
      log(`⚠️ Unknown task type: ${task.type}`);
  }
}

export function startCadeTaskProcessor() {
  const TASK_FILE = path.resolve(__dirname, "../../../memory/agent_chain_state.json");

  setInterval(() => {
    let task;
    try {
      const rawData = fs.readFileSync(TASK_FILE, 'utf8');
      log(`📡 Change detected — executing task chain`);
      task = JSON.parse(rawData);
    } catch (err) {
      log(`❌ Failed to parse task JSON: ${(err as Error).message}`);
      return;
    }

    try {
      handleTask(task);
    } catch (err) {
      log(`❌ Task processing error: ${(err as Error).message}`);
    }
  }, 3000);
}

