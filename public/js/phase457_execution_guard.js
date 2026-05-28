(() => {
  "use strict";

  // PHASE 457.17 — EXECUTION LOCK + ENTRY GUARD
  // Enforces single execution + render idempotency

  if (window.__PHASE457_EXECUTION_GUARD_ACTIVE__) return;
  window.__PHASE457_EXECUTION_GUARD_ACTIVE__ = true;

  // GLOBAL EXECUTION LOCK
  if (!window.__PHASE457_EXECUTION_LOCK__) {
    window.__PHASE457_EXECUTION_LOCK__ = {
      hasExecuted: false,
      lastPayloadHash: null
    };
  }

  function hashPayload(p) {
    try {
      return JSON.stringify(p);
    } catch {
      return null;
    }
  }

  function canExecute(payload) {
    const lock = window.__PHASE457_EXECUTION_LOCK__;

    if (lock.hasExecuted) return false;

    const hash = hashPayload(payload);
    if (!hash) return false;

    lock.lastPayloadHash = hash;
    lock.hasExecuted = true;

    return true;
  }

  function isDuplicate(payload) {
    const lock = window.__PHASE457_EXECUTION_LOCK__;
    const hash = hashPayload(payload);
    return hash && hash === lock.lastPayloadHash;
  }

  // SAFE EXECUTION WRAPPER (DOES NOT EXECUTE — ONLY GUARDS)
  window.__PHASE457_SAFE_EXECUTE__ = function(payload, renderFn) {
    if (!payload || typeof renderFn !== "function") return;

    // Reject duplicate payloads
    if (isDuplicate(payload)) return;

    // Enforce single execution
    if (!canExecute(payload)) return;

    // Execute exactly once
    renderFn(payload);
  };

})();
