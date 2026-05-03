(() => {
  "use strict";

  async function probe() {
    try {
      const res = await fetch("/api/agent-status", { cache: "no-store" });
      const data = await res.json();

      const agents = Object.keys(data || {});
      const healthy = agents.length > 0;

      console.log("[agent-status-probe]", {
        healthy,
        agents,
        timestamp: new Date().toISOString()
      });

      window.__AGENT_POOL_HEALTH = healthy;
      window.__AGENT_POOL_LAST_CHECK = Date.now();

    } catch (err) {
      console.warn("[agent-status-probe] failed", err);
      window.__AGENT_POOL_HEALTH = false;
    }
  }

  probe();
  setInterval(probe, 30000);
})();
