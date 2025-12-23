/**
 * Phase 16 – Shared Heartbeat Bus (OPS + Tasks)
 *
 * Wrap EventSource so any SSE message updates a normalized heartbeat store.
 * This avoids touching each widget’s handler code.
 *
 * Exposes:
 *   window.__HB = {
 *     record(kind, ts),
 *     get(kind),
 *     snapshot()
 *   }
 *
 * kind: "ops" | "tasks" | "reflections" | "unknown"
 */
(function () {
  const w = window;

  const STORE_KEY = "__HB";
  if (!w[STORE_KEY]) {
    const state = {
      ops: null,
      tasks: null,
      reflections: null,
      unknown: null,
    };

    w[STORE_KEY] = {
      record(kind, ts) {
        const k = state.hasOwnProperty(kind) ? kind : "unknown";
        state[k] = typeof ts === "number" ? ts : Date.now();
        return state[k];
      },
      get(kind) {
        const k = state.hasOwnProperty(kind) ? kind : "unknown";
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
    const es = new NativeEventSource(url, eventSourceInitDict);
    const kind = classify(url);

    // Update heartbeat on any message for this stream.
    const update = () => {
      try {
        w[STORE_KEY].record(kind, Date.now());
      } catch (_) {}
    };

    // Prefer addEventListener where supported.
    try {
      es.addEventListener("message", update);
    } catch (_) {}

    // Also wrap onmessage if assigned later.
    let _onmessage = null;
    Object.defineProperty(es, "onmessage", {
      get() {
        return _onmessage;
      },
      set(fn) {
        _onmessage = function (ev) {
          update();
          if (typeof fn === "function") return fn.call(es, ev);
        };
      },
      configurable: true,
    });

    return es;
  }

  HeartbeatEventSource.prototype = NativeEventSource.prototype;
  HeartbeatEventSource.__hbWrapped = true;

  w.EventSource = HeartbeatEventSource;
})();
