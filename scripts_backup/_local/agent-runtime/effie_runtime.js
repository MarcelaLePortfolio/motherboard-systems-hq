import fs from 'fs';
import path from 'path';

const STATUS_FILE = path.resolve('memory/agent_status.json');
const TICKER_LOG = path.resolve('memory/ticker.log');

function logEvent(agent, event) {
  const entry = JSON.stringify({
    timestamp: Math.floor(Date.now() / 1000),
    agent,
    event
  });
  fs.appendFileSync(TICKER_LOG, entry + '\n');
}

function setStatus(status) {
  let data = {};
  try {
    data = JSON.parse(fs.readFileSync(STATUS_FILE, 'utf8'));
  } catch {
    // fallback to empty object
  }
  data['effie'] = { status, ts: Math.floor(Date.now() / 1000) };
  fs.writeFileSync(STATUS_FILE, JSON.stringify(data, null, 2));
}

function heartbeat() {
  setStatus('online');
}

function shutdown() {
  logEvent('effie', '❌ Effie offline');
  setStatus('offline');
  process.exit();
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

// --- Initial Online State ---
logEvent('effie', '💚 Effie online');
setStatus('online');
setInterval(heartbeat, 5000);

// --- Effie main loop placeholder ---
console.log("🤖 Effie Runtime Started — Ready for tasks!");

const QUEUE_DIR = path.resolve("memory/queue");

function scanAndExecuteTasks() {
  console.log("🔍 Scanning:", QUEUE_DIR);
  const files = fs.readdirSync(QUEUE_DIR);
  for (const file of files) {
    const filePath = path.join(QUEUE_DIR, file);
    if (!file.endsWith(".json")) continue;
    let task;
    try {
      task = JSON.parse(fs.readFileSync(filePath, "utf8"));
    } catch (err) {
      console.error("❌ Failed to parse task file:", file, err);
      continue;
    }

    console.log("📦 Task received:", task);

    if (task.type === "read file") {
      try {
        const contents = fs.readFileSync(task.path, "utf8");
        console.log(`📄 Read from ${task.path}:`, contents);
        fs.unlinkSync(filePath);
      } catch (err) {
        console.error("❌ Read failed:", err.message);
      }
    }
  }
}

setInterval(scanAndExecuteTasks, 3000);
