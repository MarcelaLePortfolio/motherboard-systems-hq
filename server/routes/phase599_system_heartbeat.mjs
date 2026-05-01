export default function registerSystemHeartbeat(app) {
  app.get("/api/system-heartbeat", (_req, res) => {
    res.json({
      status: "ok",
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      agentPoolHealthy: globalThis.__AGENT_POOL_HEALTH ?? null
    });
  });
}
