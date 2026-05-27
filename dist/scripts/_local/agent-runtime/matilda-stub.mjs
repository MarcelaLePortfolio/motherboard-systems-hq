import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";
// ESM-compatible __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const statePath = path.join(__dirname, "../../../memory/agent_chain_state.json");
let state;
try {
    state = JSON.parse(fs.readFileSync(statePath, "utf8"));
}
catch {
    console.warn("⚠️ No existing state file, starting fresh");
    state = { agent: "Cade", status: "Idle", ts: 0 };
}
// Create new task
const taskId = `task-${Date.now()}`;
state.task = {
    id: taskId,
    description: "Example task"
};
state.status = "Working";
state.ts = Date.now();
// Save state
fs.writeFileSync(statePath, JSON.stringify(state, null, 2));
console.log(`📤 Matilda delegated new task to Cade: ${state.task.description}`);
