/**
 * Phase 19 — Debug helpers (Express 5 compatible)
 *
 * Endpoints (only when PHASE19_DEBUG === "1"):
 *   - GET /__debug/routes  -> list mounted routes (best-effort)
 */
function truthy(v) {
  return String(v || "").trim() === "1";
}

function listRoutes(app) {
  // Express 5 uses app.router; Express 4 often uses app._router
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

  // sort stable
  out.sort((a, b) => (a.path > b.path ? 1 : a.path < b.path ? -1 : 0));
  return out;
}

export function registerPhase19DebugRoutes(app) {
  if (!app || typeof app.get !== "function") return;

  app.get("/__debug/routes", (req, res) => {
    if (!truthy(process.env.PHASE19_DEBUG)) {
      return res.status(404).json({ ok: false, error: "not_found" });
    }
    return res.status(200).json({
      ok: true,
      ts: Date.now(),
      routes: listRoutes(app),
      note: "If routes list is empty, Express internals differ; still proves handler execution.",
    });
  });
}
