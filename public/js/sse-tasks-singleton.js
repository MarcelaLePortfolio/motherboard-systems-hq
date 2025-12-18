/**
 * Phase 13.5 — Tasks SSE Singleton + Close-Guard (dashboard-only)
 *
 * Why: we're still seeing ABORT/RECONNECT. Even with a singleton, if any
 * dashboard code calls `es.close()` (during re-init, hot reload, or widget teardown),
 * it will abort the connection and trigger reconnect churn.
 *
 * Fix: for /events/tasks only:
 * - return ONE shared EventSource instance (singleton)
 * - GUARD `.close()` so accidental closes become no-ops
 * - still allow "real" close on page unload (so the browser can cleanly exit)
 *
 * No backend/DB changes.
 */
(() => {
  "use strict";

  if (!window.EventSource) return;
  if (window.__mbhq_tasks_sse_singleton_installed) return;
  window.__mbhq_tasks_sse_singleton_installed = true;

  const NativeEventSource = window.EventSource;

  let singleton = null;
  let singletonUrl = null;
  let lastCreateAt = 0;
  let allowRealClose = false;

  function isTasksUrl(url) {
    try {
      const s = typeof url === "string" ? url : String(url);
      return s.includes("/events/tasks");
    } catch {
      return false;
    }
  }

  function isLive(es) {
    try {
      // 2 = CLOSED
      return es && typeof es.readyState === "number" && es.readyState !== 2;
    } catch {
      return false;
    }
  }

  function guardClose(es) {
    if (!es || es.__mbhq_close_guarded) return es;
    es.__mbhq_close_guarded = true;

    const realClose = es.close.bind(es);
    es.__mbhq_real_close = realClose;

    es.close = () => {
      // Only allow real close when we're unloading the page.
      if (allowRealClose) return realClose();

      // Otherwise ignore accidental closes (teardown/reinit loops).
      // Keep a tiny breadcrumb for debugging.
      try {
        es.__mbhq_close_blocked_at = Date.now();
      } catch {}
    };

    return es;
  }

  function create(url, init) {
    const es = new NativeEventSource(url, init);
    singleton = guardClose(es);
    singletonUrl = String(url);

    // If server closes it (or it truly dies), clear singleton so next call can recreate.
    es.addEventListener("error", () => {
      try {
        if (es.readyState === 2) {
          singleton = null;
          singletonUrl = null;
        }
      } catch {
        // ignore
      }
    });

    return singleton;
  }

  function TasksSafeEventSource(url, eventSourceInitDict) {
    if (!isTasksUrl(url)) {
      return new NativeEventSource(url, eventSourceInitDict);
    }

    const t = Date.now();

    // Reuse any live singleton.
    if (isLive(singleton)) return singleton;

    // Cooldown to avoid rapid-fire recreate loops.
    if (singleton && t - lastCreateAt < 750) return singleton;

    lastCreateAt = t;

    // If URL changes, prefer latest.
    if (singletonUrl && String(url) !== singletonUrl) {
      singleton = null;
      singletonUrl = null;
    }

    return create(url, eventSourceInitDict);
  }

  TasksSafeEventSource.prototype = NativeEventSource.prototype;
  window.EventSource = TasksSafeEventSource;

  // Allow real close only on unload (browser cleanup).
  window.addEventListener("beforeunload", () => {
    allowRealClose = true;
    try {
      if (singleton && singleton.__mbhq_real_close) singleton.__mbhq_real_close();
    } catch {}
  });

  // Debug handle (DevTools Console, not Terminal):
  // window.__mbhq_tasks_eventsource()
  window.__mbhq_tasks_eventsource = () => singleton;
})();
