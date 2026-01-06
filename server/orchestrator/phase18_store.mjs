/**
 * Phase 18 — In-memory orchestrator store (no persistence).
 * Guarded by PHASE18_ENABLE_ORCHESTRATION=1 at the server entrypoint.
 */

export function createInMemoryOrchestratorStore() {
  const state = {
    createdAt: Date.now(),
    tickCount: 0,
    lastTickAt: null,

    // Minimal future-facing shapes (kept intentionally tiny for Phase 18)
    agents: new Map(),     // agentId -> { lastSeenAt, status, meta }
    queue: [],             // [{ id, kind, payload, createdAt }]
    lastError: null,
  };

  return {
    getState() {
      return state;
    },

    bumpTick(now = Date.now()) {
      state.tickCount += 1;
      state.lastTickAt = now;
    },

    upsertAgent(agentId, patch, now = Date.now()) {
      const prev = state.agents.get(agentId) || { lastSeenAt: null, status: "unknown", meta: {} };
      const next = {
        ...prev,
        ...patch,
        lastSeenAt: now,
        meta: { ...(prev.meta || {}), ...(patch?.meta || {}) },
      };
      state.agents.set(agentId, next);
      return next;
    },

    enqueue(kind, payload = {}) {
      const item = {
        id: `q_${Date.now()}_${Math.random().toString(16).slice(2)}`,
        kind,
        payload,
        createdAt: Date.now(),
      };
      state.queue.push(item);
      return item;
    },

    dequeue() {
      return state.queue.shift() || null;
    },

    setError(err) {
      state.lastError = err ? { message: String(err?.message || err), at: Date.now() } : null;
    },
  };
}
