/**
 * Phase 18 — Minimal orchestration tick.
 * Intentionally does almost nothing; establishes the contract + cadence.
 */

export function orchestrationTick(store, opts = {}) {
  const now = typeof opts.now === "function" ? opts.now() : Date.now();
  const log = typeof opts.log === "function" ? opts.log : null;

  try {
    store.bumpTick(now);

    const logEvery = Number(process.env.PHASE18_TICK_LOG_EVERY || 10);
    if (log && logEvery > 0 && store.getState().tickCount % logEvery === 0) {
      log(`[phase18] tick ok tickCount=${store.getState().tickCount}`);
    }

    // Minimal “work”: drain at most one queued item per tick (future hook).
    const item = store.dequeue();
    if (item && log) log(`[phase18] tick drained item kind=${item.kind} id=${item.id}`);

    // Placeholder: later phases can reconcile agent heartbeats / run policies here.
  } catch (err) {
    store.setError(err);
    if (log) log(`[phase18] tick error: ${String(err?.stack || err)}`);
  }
}
