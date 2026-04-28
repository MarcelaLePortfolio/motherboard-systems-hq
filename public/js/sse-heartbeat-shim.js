/**
 * Phase 16 – Shared Heartbeat Bus (OPS + Tasks)
 *
 * SINGLE-OWNER BOOTSTRAP GUARD (Phase16 consolidated)
 */
(function () {
  const w = window;

  if (w.__PHASE16_SSE_OWNER_STARTED) return;
  w.__PHASE16_SSE_OWNER_STARTED = true;

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
    if (u.includes("/events/task-events") || u.includes("/events/tasks")) return "tasks";
    if (u.includes("/events/reflections")) return "reflections";
    return "unknown";
  }

  function HeartbeatEventSource(url, eventSourceInitDict) {
    const kind = classify(url);

    try { w[STORE_KEY].record(kind, Date.now()); } catch (_) {}

    const es = new NativeEventSource(url, eventSourceInitDict);

    const update = () => {
      try { w[STORE_KEY].record(kind, Date.now()); } catch (_) {}
    };

    try { es.addEventListener("open", update); } catch (_) {}
    try { es.addEventListener("message", update); } catch (_) {}

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

    try { es.addEventListener("error", update); } catch (_) {}

    return es;
  }

  HeartbeatEventSource.prototype = NativeEventSource.prototype;
  HeartbeatEventSource.__hbWrapped = true;

  w.EventSource = HeartbeatEventSource;
})();
