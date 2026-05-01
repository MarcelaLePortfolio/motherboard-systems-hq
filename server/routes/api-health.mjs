export default function registerHealthRoutes(app) {
  // Existing health endpoint (preserved)
  app.get("/api/health", (_req, res) => {
    res.json({
      status: "ok",
      timestamp: new Date().toISOString(),
      uptime: process.uptime()
    });
  });

  // Phase599 Safe Heartbeat (inline, no new loader required)
  app.get("/api/system-heartbeat", (_req, res) => {
    res.json({
      status: "ok",
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      agentPoolHealthy: globalThis.__AGENT_POOL_HEALTH ?? null
    });
  });
}
