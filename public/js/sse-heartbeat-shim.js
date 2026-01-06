/**
 * Phase 16 – Shared Heartbeat Bus (OPS + Tasks)
 *
 * Wrap EventSource so connection + any SSE message updates a normalized heartbeat store.
 *
 * Exposes:
 *   window.__HB = { record(kind, ts), get(kind), snapshot() }
 *
 * kind: "ops" | "tasks" | "reflections" | "unknown"
 */
(function () {
  const w = window;

  const STORE_KEY = "__HB";
  if (!w[STORE_KEY]) {
    const state = { ops: null, tasks: null, reflections: null, unknown: null };
    w[STORE_KEY] = {
      record(kind, ts) {
        const k = Object.prototype.hasOwnProperty.call(state, kind) ? kind : "unknown";
        state[k] = typeof ts === "number" ? ts : Date.now();
        return state[k];
      },
      get(kind) {
        const k = Object.prototype.hasOwnProperty.call(state, kind) ? kind : "unknown";
        return state[k];
      },
      snapshot() {
        return { ...state };
      },
    };
  }

  const NativeEventSource = w.EventSource;
  if (!NativeEventSource || NativeEventSource.__hbWrapped) return;

  function classify(url) {
    const u = String(url || "");
    if (u.includes("/events/ops")) return "ops";
    if (u.includes("/events/tasks")) return "tasks";
    if (u.includes("/events/reflections")) return "reflections";
    return "unknown";
  }

  function HeartbeatEventSource(url, eventSourceInitDict) {
    const kind = classify(url);

    // Record immediately on connection attempt so "connected but quiet" still looks alive.
    try { w[STORE_KEY].record(kind, Date.now()); } catch (_) {}

    const es = new NativeEventSource(url, eventSourceInitDict);

    const update = () => {
      try { w[STORE_KEY].record(kind, Date.now()); } catch (_) {}
    };

    // Update heartbeat when the connection opens (most reliable for "alive").
    try { es.addEventListener("open", update); } catch (_) {}

    // Update heartbeat on any message for this stream.
    try { es.addEventListener("message", update); } catch (_) {}

    // Also wrap onmessage if assigned later.
    let _onmessage = null;
    Object.defineProperty(es, "onmessage", {
      get() { return _onmessage; },
      set(fn) {
        _onmessage = function (ev) {
          update();
          if (typeof fn === "function") return fn.call(es, ev);
        };
      },
      configurable: true,
    });

    // Update heartbeat when errors occur too (helps show "something happened" vs silence).
    try { es.addEventListener("error", update); } catch (_) {}

    return es;
  }

  HeartbeatEventSource.prototype = NativeEventSource.prototype;
  HeartbeatEventSource.__hbWrapped = true;

  w.EventSource = HeartbeatEventSource;
})();
