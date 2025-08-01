import fs from 'fs';
import readline from 'readline';

const TICKER_LOG = './ui/dashboard/ticker-events.log';
const STATUS_FILE = './memory/agent_status.json';

// Utility to log to ticker
function logEvent(agent, event) {
  const entry = JSON.stringify({
    timestamp: Math.floor(Date.now() / 1000),
    agent,
    event
  });
  fs.appendFileSync(TICKER_LOG, entry + "\n");
}

// Update agent status JSON
function setStatus(status) {
  let current = {};
  if (fs.existsSync(STATUS_FILE)) {
    try { current = JSON.parse(fs.readFileSync(STATUS_FILE, 'utf8')); } catch {}
  }
  current.cade = status;
  fs.writeFileSync(STATUS_FILE, JSON.stringify(current, null, 2));
}

// Handle exit cleanly
function shutdown() {
  logEvent('cade', '❌ Cade offline');
  setStatus('offline');
  process.exit();
}
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

// Mark online at startup
logEvent('cade', '💚 Cade online');
setStatus('online');

// Cade's reasoning loop
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
