// ./scripts/agents/agent-heartbeat.ts
import os from "os";
import fs from "fs";
import path from "path";
import { setInterval } from "timers";

const HEARTBEAT_INTERVAL_MS = 5000;
const heartbeatPath = path.join(process.cwd(), "public/tmp/heartbeat.json");

function getAgentStats(){
  return {
    timestamp: new Date().toISOString(),
    cpuLoad: os.loadavg()[0],
    freeMem: os.freemem(),
    totalMem: os.totalmem(),
    uptime: os.uptime()
  };
}

function writeHeartbeat(){
  const stats = getAgentStats();
  fs.writeFileSync(heartbeatPath, JSON.stringify(stats, null, 2), "utf8");
  console.log(`[HEARTBEAT] Updated at ${stats.timestamp}`);
}

console.log("Agent Heartbeat starting...");
setInterval(writeHeartbeat, HEARTBEAT_INTERVAL_MS);
