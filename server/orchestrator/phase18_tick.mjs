/**
 * Phase 18 — Minimal orchestration tick.
 * Intentionally does almost nothing; establishes the contract + cadence.
 */

export function orchestrationTick(store, opts = {}) {
  const now = typeof opts.now === "function" ? opts.now() : Date.now();
  const log = typeof opts.log === "function" ? opts.log : null;

  try {
    store.bumpTick(now);

    // Minimal “work”: drain at most one queued item per tick (future hook).
    const item = store.dequeue();
    if (item && log) log(`[phase18] tick drained item kind=${item.kind} id=${item.id}`);

    // Placeholder: later phases can reconcile agent heartbeats / run policies here.
  } catch (err) {
    store.setError(err);
    if (log) log(`[phase18] tick error: ${String(err?.stack || err)}`);
  }
}
