import fs from 'fs';
import readline from 'readline';
import path from 'path';

const STATUS_FILE = path.resolve('memory/agent_status.json');
const TICKER_LOG = path.resolve('ui/dashboard/ticker-events.log');

function logEvent(agent, event) {
  const entry = JSON.stringify({
    timestamp: Math.floor(Date.now() / 1000),
    agent,
    event
  });
  fs.appendFileSync(TICKER_LOG, entry + "\n");
}

function setStatus(status) {
  const now = Math.floor(Date.now() / 1000);
  let data = {};
  try { data = JSON.parse(fs.readFileSync(STATUS_FILE, 'utf-8')); } catch {}
  data.cade = { status, lastHeartbeat: now };
  fs.writeFileSync(STATUS_FILE, JSON.stringify(data, null, 2));
}

function heartbeat() {
  setStatus('online');
}

// Graceful shutdown
function shutdown() {
  logEvent('cade', '❌ Cade offline');
  setStatus('offline');
  process.exit();
}
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

// Initial online mark + heartbeat loop
logEvent('cade', '💚 Cade online');
setStatus('online');
setInterval(heartbeat, 5000); // heartbeat every 5 seconds

// Cade Reasoning Loop
async function startCade() {
  console.log("🤖 Cade Reasoning Mode Started — Enter high-level goals:");

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: true
  });

  rl.on('line', async (goal) => {
    if (!goal.trim()) return;

    logEvent("cade", `Received goal: "${goal}"`);

    const steps = [
      `Analyze goal: "${goal}"`,
      `Break into smaller actionable steps`,
      `List dependencies or files involved`,
      `Plan safe execution order`,
      `Prepare to dry-run (Phase 2)`
    ];

    for (const step of steps) {
      logEvent("cade", step);
      console.log(`CADE: ${step}`);
      await new Promise(r => setTimeout(r, 1000));
    }

    logEvent("cade", `✅ Planning complete for: "${goal}"`);
  });
}

startCade();
