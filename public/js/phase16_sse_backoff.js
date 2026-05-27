/**
 * Phase 16.5 — SSE reconnect/backoff helper (strict single-connection)
 *
 * Usage:
 *   const es = window.connectSSEWithBackoff({
 *     url: "/events/ops",
 *     label: "ops",
 *     isHealthyEvent: (name, ev) => name === "heartbeat" || name === "hello" || name === "ops.state",
 *     onError: (ev) => {},
 *     onState: (st) => {},
 *   });
 *
 * Guarantees:
 * - At most ONE underlying EventSource at any moment
 * - On reconnect: closes old ES before opening new ES
 * - Only ONE retry timer
 * - Resets attempt counter when "healthy" events arrive
 */
(function () {
  if (window.connectSSEWithBackoff) return;

  function now() { return Date.now(); }

  function clamp(n, lo, hi) { return Math.max(lo, Math.min(hi, n)); }

  function computeDelayMs(attempt, baseMs, maxMs, jitterFrac) {
    // attempt: 0,1,2...
    const exp = baseMs * Math.pow(2, clamp(attempt, 0, 20));
    const raw = Math.min(maxMs, exp);
    const jitter = raw * (jitterFrac || 0);
    const j = (Math.random() * 2 - 1) * jitter; // +/- jitter
    return Math.max(0, Math.round(raw + j));
  }

  window.connectSSEWithBackoff = function connectSSEWithBackoff(cfg) {
    cfg = cfg || {};
    const url = cfg.url;
    if (!url) throw new Error("connectSSEWithBackoff: missing cfg.url");

    const baseMs = typeof cfg.baseDelayMs === "number" ? cfg.baseDelayMs : 500;
    const maxMs  = typeof cfg.maxDelayMs  === "number" ? cfg.maxDelayMs  : 30000;
    const jitter = typeof cfg.jitterFrac  === "number" ? cfg.jitterFrac  : 0.2;

    let es = null;
    let closed = false;
    let connecting = false;
    let attempt = 0;
    let lastEventAt = 0;
    let retryTimer = null;

    // user listeners (EventSource-like)
    const listeners = new Map(); // name -> Set(fn)

    function safe(fn) { try { fn && fn(); } catch (_) {} }

    function emit(phase, extra) {
      if (!cfg.onState) return;
      try {
        cfg.onState({
          label: cfg.label || url,
          url,
          attempt,
          phase,
          lastEventAt,
          readyState: es ? es.readyState : null,
          ...(extra || {}),
        });
      } catch (_) {}
    }

    function closeES() {
      if (es) {
        try { es.close(); } catch (_) {}
      }
      es = null;
    }

    function clearRetry() {
      if (retryTimer) {
        clearTimeout(retryTimer);
        retryTimer = null;
      }
    }

    function scheduleRetry(reason) {
      if (closed) return;
      clearRetry();
      const ms = computeDelayMs(attempt, baseMs, maxMs, jitter);
      emit("retry_scheduled", { reason, delayMs: ms });
      attempt += 1;
      retryTimer = setTimeout(() => {
        retryTimer = null;
        connect("retry");
      }, ms);
    }

    function wrapListener(name, fn) {
      return function (ev) {
        lastEventAt = now();
        try {
          if (cfg.isHealthyEvent && cfg.isHealthyEvent(name, ev)) {
            attempt = 0;
            emit("healthy", { event: name });
          }
        } catch (_) {}
        try { fn(ev); } catch (_) {}
      };
    }

    function attachAllListeners() {
      if (!es) return;
      for (const [name, set] of listeners.entries()) {
        for (const fn of set.values()) {
          try { es.addEventListener(name, wrapListener(name, fn)); } catch (_) {}
        }
      }
    }

    function connect(reason) {
      if (closed) return;
      if (connecting) return; // prevent concurrent connects
      connecting = true;

      clearRetry();

      // IMPORTANT: ensure ONLY ONE ES exists
      closeES();

      emit("connecting", { reason });

      try {
        es = new EventSource(url);
      } catch (e) {
        connecting = false;
        emit("error", { reason: "new_failed" });
        scheduleRetry("new_failed");
        return;
      }

      // Attach user listeners first (so early events are caught)
      attachAllListeners();

      // open/error handlers
      safe(() => es.addEventListener("open", () => {
        connecting = false;
        attempt = 0;
        emit("open");
      }));

      safe(() => es.addEventListener("error", (ev) => {
        connecting = false;
        emit("error");
        // Close before retry so we don't stack sockets.
        safe(() => es && es.close());
        closeES();
        if (cfg.onError) safe(() => cfg.onError(ev));
        scheduleRetry("error");
      }));
    }

    const wrapper = {
      addEventListener(name, fn) {
        if (!name || typeof fn !== "function") return;
        if (!listeners.has(name)) listeners.set(name, new Set());
        listeners.get(name).add(fn);
        // If already connected, attach immediately.
        if (es) {
          try { es.addEventListener(name, wrapListener(name, fn)); } catch (_) {}
        }
      },
      removeEventListener(name, fn) {
        const set = listeners.get(name);
        if (set) set.delete(fn);
        // Best-effort remove on underlying ES (won't match wrapped fn; acceptable for Phase16 usage).
        try { es && es.removeEventListener && es.removeEventListener(name, fn); } catch (_) {}
      },
      close() {
        closed = true;
        clearRetry();
        closeES();
        emit("closed");
      },
    };

    Object.defineProperty(wrapper, "readyState", {
      get() { return es ? es.readyState : (closed ? 2 : 0); },
    });

    // kick off
    connect("initial");
    return wrapper;
  };
})();
