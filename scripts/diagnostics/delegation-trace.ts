import fetch from "node-fetch";
import fs from "fs";
import path from "path";

/**
 * Delegation Trace Utility
 * -------------------------------------
 * Verifies that Matilda → Cade message delegation works end-to-end.
 * Logs each phase to /logs/delegation-trace.log for review.
 */

const LOG_PATH = path.join(process.cwd(), "logs", "delegation-trace.log");

function log(msg: string) {
  const line = `[${new Date().toISOString()}] ${msg}\n`;
  fs.appendFileSync(LOG_PATH, line);
  console.log(line.trim());
}

async function main() {
  log("🚀 Starting delegation trace sequence...");

  // 1. Ping Matilda endpoint
  try {
    const res = await fetch("http://localhost:3001/matilda", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        message: "Test delegation: create /agents/status endpoint via Cade",
      }),
    });
    const data = await res.json();
    log(`📡 Matilda responded: ${JSON.stringify(data)}`);
  } catch (err) {
    log(`❌ Error pinging Matilda: ${err}`);
  }

  // 2. Check if Cade picked up the task
  try {
    const status = await fetch("http://localhost:3001/agents/status");
    const data = await status.json();
    log(`🧠 Cade status: ${JSON.stringify(data)}`);
  } catch (err) {
    log(`⚠️ Cade status check failed: ${err}`);
  }

  // 3. Query Chronicle for new delegation events
  try {
    const chron = await fetch("http://localhost:3001/chronicle/list");
    const logData = await chron.json();
    const filtered = logData.log?.filter((e: any) =>
      e.event.includes("agent.status.endpoint")
    );
    log(`📜 Chronicle entries: ${JSON.stringify(filtered)}`);
  } catch (err) {
    log(`⚠️ Chronicle fetch error: ${err}`);
  }

  log("✅ Delegation trace complete. Review logs/delegation-trace.log for full details.");
}

main();
