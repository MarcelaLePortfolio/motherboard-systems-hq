import { execSync } from "child_process";
import os from "os";

export async function startWatchdog() {
  console.log("<0001fa99> 🕐 Agent Watchdog active (2-minute timeout)");

  const checkAgents = () => {
    try {
      const output = execSync("pm2 jlist", { encoding: "utf8" });
      const agents = JSON.parse(output);

      const now = Date.now();
      for (const agent of agents) {
        const name = agent.name;
        const uptime = agent.pm2_env.pm_uptime;
        const restartCount = agent.pm2_env.restart_time;
        const status = agent.pm2_env.status;

        if (status !== "online") {
          console.warn(`⚠️  ${name} status=${status}, restarting…`);
          execSync(`pm2 restart ${name}`);
          continue;
        }

        // If idle for > 2 minutes (no restart and old uptime), restart it
        if (now - uptime > 120000 && restartCount === 0) {
          console.log(`🔄 ${name} idle > 2 min — restarting`);
          execSync(`pm2 restart ${name}`);
        }
      }
    } catch (err) {
      console.error("<0001fa99> ❌ Watchdog error:", err.message);
    }
  };

  // Run every minute
  setInterval(checkAgents, 60000);
}
