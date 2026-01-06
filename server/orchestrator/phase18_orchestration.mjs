/**
 * Phase 18 — In-memory orchestrator runtime.
 * Gated by PHASE18_ENABLE_ORCHESTRATION=1.
 */

import { createInMemoryOrchestratorStore } from "./phase18_store.mjs";
import { orchestrationTick } from "./phase18_tick.mjs";

export function startPhase18OrchestrationRuntime(options = {}) {
  const intervalMs = Number(options.intervalMs || 1000);
  const log =
    typeof options.log === "function"
      ? options.log
      : (msg) => console.log(msg);

  const store = createInMemoryOrchestratorStore();

  // Seed a single “boot” event so we can see first drain without extra wiring.
  store.enqueue("boot", { at: Date.now() });

  log(`[phase18] orchestration runtime starting (intervalMs=${intervalMs})`);

  const timer = setInterval(() => {
    orchestrationTick(store, { log, now: () => Date.now() });
  }, intervalMs);

  // Allow clean shutdown if needed.
  return {
    store,
    stop() {
      clearInterval(timer);
      log("[phase18] orchestration runtime stopped");
    },
  };
}
