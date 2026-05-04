/**
 * Phase 19 — Orchestrator State Route (read-only)
 *
 * Problem observed (Jan 6, 2026):
 * - process.env has correct values at server boot logs
 * - but inside request handlers, process.env.* is undefined (JSON omits keys => env:{})
 *
 * Fix:
 * - Snapshot the relevant env vars at module-load time (when they ARE present)
 * - Use the snapshot for gating + reporting
 *
 * Gate:
 *   - PHASE19_ENABLE_ORCH_STATE === "1" (SNAPSHOT)
 *
 * Endpoints:
 *   - GET /orchestrator/state         (gated JSON snapshot)
 *   - GET /orchestrator/state._debug  (always 200; shows snapshot vs live env)
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

  const orch = pickFirstDefined(g.__orchestrator, g.__orch, g.__orchestratorRuntime);

  if (orch) {
    if (typeof orch.snapshot === "function") return { ok: true, state: orch.snapshot() };
    if (typeof orch.getState === "function") return { ok: true, state: orch.getState() };
    if (typeof orch.state === "object") return { ok: true, state: orch.state };
  }

  return { ok: false, state: null };
}

export function registerOrchestratorStateRoute(app) {
  const PHASE19_SNAPSHOT = Object.freeze({
    PHASE18_ENABLE_ORCHESTRATION: process.env.PHASE18_ENABLE_ORCHESTRATION,
    PHASE19_ENABLE_ORCH_STATE: process.env.PHASE19_ENABLE_ORCH_STATE,
    PHASE19_DEBUG: process.env.PHASE19_DEBUG,
  });
  const PHASE19_GATE_ON = truthy(PHASE19_SNAPSHOT.PHASE19_ENABLE_ORCH_STATE);
  const PHASE18_ENABLED = truthy(PHASE19_SNAPSHOT.PHASE18_ENABLE_ORCHESTRATION);

  if (!app || typeof app.get !== "function") {
    throw new Error("registerOrchestratorStateRoute(app) requires an Express app");
  }

  console.log("[phase19] orchestrator_state_route mounted", {
    file: import.meta.url,
    envSnapshot: {
      PHASE18_ENABLE_ORCHESTRATION: PHASE19_SNAPSHOT.PHASE18_ENABLE_ORCHESTRATION,
      PHASE19_ENABLE_ORCH_STATE: PHASE19_SNAPSHOT.PHASE19_ENABLE_ORCH_STATE,
    },
  });

  // Debug: ALWAYS 200 so we can see snapshot vs live env at request time
  app.get("/orchestrator/state._debug", (req, res) => {
    res.setHeader("X-Phase19-Orch", "1");
    return res.status(200).json({
      ok: true,
      ts: Date.now(),
      envSnapshot: {
        PHASE18_ENABLE_ORCHESTRATION: PHASE19_SNAPSHOT.PHASE18_ENABLE_ORCHESTRATION,
        PHASE19_ENABLE_ORCH_STATE: PHASE19_SNAPSHOT.PHASE19_ENABLE_ORCH_STATE,
        PHASE19_DEBUG: PHASE19_SNAPSHOT.PHASE19_DEBUG,
      },
      snapshotKeys: Object.keys(PHASE19_SNAPSHOT),
      snapshotOwnProps: Object.getOwnPropertyNames(PHASE19_SNAPSHOT),
      gate: { PHASE19_GATE_ON, PHASE18_ENABLED },
      envLive: {
        PHASE18_ENABLE_ORCHESTRATION: process.env.PHASE18_ENABLE_ORCHESTRATION,
        PHASE19_ENABLE_ORCH_STATE: process.env.PHASE19_ENABLE_ORCH_STATE,
        PHASE19_DEBUG: process.env.PHASE19_DEBUG,
      },
      note:
        "If envLive.* is missing/undefined but envSnapshot has values, something is mutating/clearing process.env after boot; Phase 19 uses envSnapshot for gating.",
    });
  });

  app.get("/orchestrator/state", (req, res) => {
    res.setHeader("X-Phase19-Orch", "1");

    // Gate uses the SNAPSHOT (not process.env)
    if (!PHASE19_GATE_ON) {
      return res.status(404).json({
        ok: false,
        error: "not_found",
        debug: {
          gate: "snapshot",
          PHASE19_ENABLE_ORCH_STATE: PHASE19_SNAPSHOT.PHASE19_ENABLE_ORCH_STATE,
          PHASE18_ENABLE_ORCHESTRATION: PHASE19_SNAPSHOT.PHASE18_ENABLE_ORCHESTRATION,
        },
      });
    }

    const enabled = PHASE18_ENABLED;
    const { ok, state } = readStateFromGlobals();

    return res.status(200).json({
      ok: true,
      enabled,
      available: ok,
      ts: Date.now(),
      state: ok ? safeClone(state) : null,
      note: ok ? undefined : "orchestrator state not found on expected globals",
    });
  });
}
