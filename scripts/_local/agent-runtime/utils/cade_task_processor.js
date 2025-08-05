// Cade Task Processor – Guaranteed Logging Mode
import fs from 'fs';
import path from 'path';

const TASK_FILE = path.resolve('scripts/_local/agent-runtime/utils/cade_task.json');
const DASHBOARD_HTML = path.resolve('ui/dashboard/index.html');
let lastTimestamp = 0;

function log(msg) {
  console.log(`⚡ Cade Task Processor: ${msg}`);
}

export function startCadeTaskProcessor() {
  log("Polling every 3s...");
  setInterval(() => {
    try {
      log("Heartbeat - checking for task...");
      if (!fs.existsSync(TASK_FILE)) return;

      const taskData = JSON.parse(fs.readFileSync(TASK_FILE, 'utf-8'));
      if (!taskData.task || taskData.timestamp <= lastTimestamp) return;

      lastTimestamp = taskData.timestamp;
      const task = taskData.task;
      log(`Executing: ${task}`);

      if (task.includes("Append a test line")) {
        fs.appendFileSync(DASHBOARD_HTML, "\n<!-- Cade was here -->\n");
        log("✅ Test line appended to index.html");
      } else if (task.toLowerCase().includes("inject start/stop/restart buttons")) {
        const snippet = `
<div class="settings-panel">
  <div class="button-group">
    <button id="start-button">Start</button>
    <button id="stop-button">Stop</button>
    <button id="restart-button">Restart</button>
  </div>
</div>
<!-- Cade auto-injected buttons -->
`;
        fs.appendFileSync(DASHBOARD_HTML, snippet);
        log("✅ Buttons injected into index.html");
      } else {
        log("⚠️ Task not recognized for automated execution");
      }
    } catch (err) {
      log(`❌ Error: ${err.stack}`);
    }
  }, 3000);
}
