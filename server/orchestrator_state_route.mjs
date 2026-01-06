/**
 * Phase 19 — Orchestrator State Route (read-only)
 *
 * Gate: PHASE19_ENABLE_ORCH_STATE === "1"
 * Debug gate: PHASE19_DEBUG === "1"
 *
 * Endpoints:
 *   - GET /orchestrator/state         (gated JSON snapshot)
 *   - GET /orchestrator/state._debug  (only when PHASE19_DEBUG=1)
 */

function truthy(v) {
  return String(v || "").trim() === "1";
}

function pickFirstDefined(...vals) {
  for (const v of vals) if (v !== undefined) return v;
  return undefined;
}

function safeClone(obj) {
  try {
    return JSON.parse(JSON.stringify(obj));
  } catch {
    return { kind: "nonserializable", note: "state could not be JSON-stringified" };
  }
}

function readStateFromGlobals() {
  const g = globalThis;

  const store =
    pickFirstDefined(
      g.__orchestratorStore,
      g.__orchStore,
      g.__orchestrator?.store,
      g.__orchestrator?.orchestratorStore,
      g.__orchestrator?.stateStore
    );

  if (store) {
    if (typeof store.snapshot === "function") return { ok: true, state: store.snapshot() };
    if (typeof store.getState === "function") return { ok: true, state: store.getState() };
    if (typeof store.toJSON === "function") return { ok: true, state: store.toJSON() };
    if (typeof store === "object") return { ok: true, state: store };
  }

  const orch =
    pickFirstDefined(
      g.__orchestrator,
      g.__orch,
      g.__orchestratorRuntime
    );

  if (orch) {
    if (typeof orch.snapshot === "function") return { ok: true, state: orch.snapshot() };
    if (typeof orch.getState === "function") return { ok: true, state: orch.getState() };
    if (typeof orch.state === "object") return { ok: true, state: orch.state };
  }

  return { ok: false, state: null };
}

export function registerOrchestratorStateRoute(app) {
  if (process.env.PHASE19_DEBUG === "1") {
    console.log("[phase19] orchestrator_state_route loaded", { file: import.meta.url });
  }
  if (!app || typeof app.get !== "function") {
    throw new Error("registerOrchestratorStateRoute(app) requires an Express app");
  }

  if (truthy(process.env.PHASE19_DEBUG)) {
    console.log("[phase19] registerOrchestratorStateRoute(): attaching /orchestrator/state + /orchestrator/state._debug");
  }

  // Debug: prove this module is mounted + show env values (only when PHASE19_DEBUG=1)
  app.get("/orchestrator/state._debug", (req, res) => {
    res.setHeader("X-Phase19-Orch", "1");
    if (!truthy(process.env.PHASE19_DEBUG)) {
      return res.status(404).json({ ok: false, error: "not_found" });
    }
    if (truthy(process.env.PHASE19_DEBUG)) {
      console.log("[phase19] HIT /orchestrator/state._debug");
    }
    return res.status(200).json({
      ok: true,
      ts: Date.now(),
      env: {
        PHASE18_ENABLE_ORCHESTRATION: process.env.PHASE18_ENABLE_ORCHESTRATION,
        PHASE19_ENABLE_ORCH_STATE: process.env.PHASE19_ENABLE_ORCH_STATE,
        PHASE19_DEBUG: process.env.PHASE19_DEBUG,
      },
      note: "If you can see this, orchestrator_state_route.mjs is mounted on the running server.",
    });
  });

  app.get("/orchestrator/state", (req, res) => {
    res.setHeader("X-Phase19-Orch", "1");
    if (truthy(process.env.PHASE19_DEBUG)) {
      console.log("[phase19] HIT /orchestrator/state");
    }

    if (!truthy(process.env.PHASE19_ENABLE_ORCH_STATE)) {
      if (truthy(process.env.PHASE19_DEBUG)) {
        return res.status(404).json({
          ok: false,
          error: "not_found",
          debug: {
            PHASE19_ENABLE_ORCH_STATE: process.env.PHASE19_ENABLE_ORCH_STATE,
            PHASE19_DEBUG: process.env.PHASE19_DEBUG,
          },
        });
      }
      return res.status(404).json({ ok: false, error: "not_found" });
    }

    const enabled = truthy(process.env.PHASE18_ENABLE_ORCHESTRATION);
    const { ok, state } = readStateFromGlobals();

    const payload = {
      ok: true,
      enabled,
      available: ok,
      ts: Date.now(),
      state: ok ? safeClone(state) : null,
      note: ok ? undefined : "orchestrator state not found on expected globals",
    };

    return res.status(200).json(payload);
  });
}
