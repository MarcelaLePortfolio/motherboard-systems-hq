/**
 * Phase 13.5 — Tasks SSE Hard Singleton + Close-Guard + Debug (dashboard-only)
 *
 * Strict reuse of /events/tasks EventSource to prevent connect/abort churn.
 * Dashboard-only. No backend or DB changes.
 */
(() => {
  "use strict";

  if (!window.EventSource) return;
  if (window.__mbhq_tasks_sse_singleton_installed_v2) return;
  window.__mbhq_tasks_sse_singleton_installed_v2 = true;

  const NativeEventSource = window.EventSource;

  let singleton = null;
  let singletonUrl = null;
  let singletonCreatedAt = 0;
  let allowRealClose = false;

  function dbgEnabled() {
    try { return localStorage.getItem("__mbhq_debug_tasks_sse") === "1"; } catch { return false; }
  }
  function dbg(...args) {
    if (!dbgEnabled()) return;
    try { console.log("[tasks-sse]", ...args); } catch {}
  }

  function isTasksUrl(url) {
    try {
      const s = typeof url === "string" ? url : String(url);
      return s.includes("/events/tasks");
    } catch {
      return false;
    }
  }

  function readyStateSafe(es) {
    try { return es && typeof es.readyState === "number" ? es.readyState : -1; } catch { return -1; }
  }

  function definitelyClosed(es) {
    return readyStateSafe(es) === 2; // CLOSED
  }

  function guardClose(es) {
    if (!es || es.__mbhq_close_guarded) return es;
    es.__mbhq_close_guarded = true;

    const realClose = es.close.bind(es);
    es.__mbhq_real_close = realClose;

    es.close = () => {
      if (allowRealClose) return realClose();
      try { es.__mbhq_close_blocked_at = Date.now(); } catch {}
      dbg("close() blocked", { readyState: readyStateSafe(es) });
    };

    return es;
  }

  function create(url, init) {
    const es = new NativeEventSource(url, init);
    singleton = guardClose(es);
    singletonUrl = String(url);
    singletonCreatedAt = Date.now();

    dbg("CREATED singleton", { url: singletonUrl, readyState: readyStateSafe(singleton) });

    es.addEventListener("open", () => dbg("OPEN", { readyState: readyStateSafe(es) }));
    es.addEventListener("error", () => dbg("ERROR", { readyState: readyStateSafe(es) }));
    es.addEventListener("message", () => dbg("MESSAGE"));

    es.addEventListener("error", () => {
      try {
        if (definitelyClosed(es)) {
          dbg("CLOSED (via error), clearing singleton");
          singleton = null;
          singletonUrl = null;
          singletonCreatedAt = 0;
        }
      } catch {}
    });

    return singleton;
  }

  function TasksSafeEventSource(url, eventSourceInitDict) {
    if (!isTasksUrl(url)) return new NativeEventSource(url, eventSourceInitDict);

    const u = String(url);
    const now = Date.now();

    if (singleton) {
      const rs = readyStateSafe(singleton);

      if (singletonUrl && u !== singletonUrl) {
        dbg("URL mismatch but reusing singleton", { want: u, have: singletonUrl });
      }

      if (rs === 2) {
        const age = now - singletonCreatedAt;
        if (age < 5000) {
          dbg("Singleton CLOSED but fresh; reusing", { ageMs: age });
          return singleton;
        }
        dbg("Singleton CLOSED and stale; recreating", { ageMs: age });
        singleton = null;
        singletonUrl = null;
        singletonCreatedAt = 0;
        return create(u, eventSourceInitDict);
      }

      dbg("Reusing singleton", { readyState: rs });
      return singleton;
    }

    return create(u, eventSourceInitDict);
  }

  TasksSafeEventSource.prototype = NativeEventSource.prototype;
  window.EventSource = TasksSafeEventSource;

  window.addEventListener("beforeunload", () => {
    allowRealClose = true;
    try {
      if (singleton && singleton.__mbhq_real_close) singleton.__mbhq_real_close();
    } catch {}
  });

  // DevTools Console helper (not Terminal)
  window.__mbhq_tasks_eventsource = () => singleton;
})();
