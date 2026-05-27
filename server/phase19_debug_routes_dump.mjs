/**
 * Phase 19 — Debug helpers
 *
 * NOTE: These endpoints are intended for local dev only.
 * They DO NOT require PHASE19_DEBUG to respond (to diagnose env gating issues).
 *
 * Endpoints:
 *   - GET /__debug/routes  -> list mounted routes (best-effort)
 */
function listRoutes(app) {
  const router = app?.router || app?._router;
  const stack = router?.stack || [];
  const out = [];

  for (const layer of stack) {
    const route = layer?.route;
    if (!route) continue;
    const path = route.path;
    const methods = Object.keys(route.methods || {}).filter((m) => route.methods[m]);
    out.push({ path, methods });
  }

  out.sort((a, b) => (a.path > b.path ? 1 : a.path < b.path ? -1 : 0));
  return out;
}

export function registerPhase19DebugRoutes(app) {
  if (!app || typeof app.get !== "function") return;

  app.get("/__debug/routes", (req, res) => {
    res.setHeader("X-Phase19-Debug", "1");
    return res.status(200).json({
      ok: true,
      ts: Date.now(),
      env: {
        PHASE18_ENABLE_ORCHESTRATION: process.env.PHASE18_ENABLE_ORCHESTRATION,
        PHASE19_ENABLE_ORCH_STATE: process.env.PHASE19_ENABLE_ORCH_STATE,
        PHASE19_DEBUG: process.env.PHASE19_DEBUG,
      },
      routes: listRoutes(app),
      note: "If routes is empty, Express internals differ; still proves handler execution + env visibility.",
    });
  });
}
