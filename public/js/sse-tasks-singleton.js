/**
 * Phase 13.5 — Tasks SSE Singleton Patch (dashboard-only)
 *
 * Goal: prevent accidental connect/abort thrash by ensuring there is only ONE
 * EventSource instance for /events/tasks across the page.
 *
 * No backend/DB changes. Safe-by-default:
 * - Only intercepts URLs containing "/events/tasks"
 * - Returns a shared singleton EventSource for that URL
 */
(() => {
  "use strict";

  if (!window.EventSource) return;
  if (window.__mbhq_tasks_sse_singleton_installed) return;
  window.__mbhq_tasks_sse_singleton_installed = true;

  const NativeEventSource = window.EventSource;

  // Global singleton state
  let singleton = null;
  let singletonUrl = null;
  let lastCreateAt = 0;

  function isTasksUrl(url) {
    try {
      const s = typeof url === "string" ? url : String(url);
      return s.includes("/events/tasks");
    } catch {
      return false;
    }
  }

  function shouldReuse(es) {
    try {
      // 2 = CLOSED
      return es && typeof es.readyState === "number" && es.readyState !== 2;
    } catch {
      return false;
    }
  }

  function create(url, init) {
    const es = new NativeEventSource(url, init);
    singleton = es;
    singletonUrl = String(url);

    // If the singleton dies, allow recreation on next request (with tiny cooldown).
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

    return es;
  }

  function TasksSafeEventSource(url, eventSourceInitDict) {
    if (!isTasksUrl(url)) {
      return new NativeEventSource(url, eventSourceInitDict);
    }

    const now = Date.now();

    // If we already have a live one, always reuse it.
    if (shouldReuse(singleton)) {
      return singleton;
    }

    // Cooldown to prevent rapid-fire create/abort loops from repeated constructors.
    if (now - lastCreateAt < 750 && singleton) {
      return singleton;
    }

    lastCreateAt = now;

    // If we had one but it's closed, recreate.
    if (singleton && !shouldReuse(singleton)) {
      singleton = null;
      singletonUrl = null;
    }

    // If URL changed, prefer latest.
    if (singletonUrl && String(url) !== singletonUrl) {
      singleton = null;
      singletonUrl = null;
    }

    return create(url, eventSourceInitDict);
  }

  TasksSafeEventSource.prototype = NativeEventSource.prototype;
  window.EventSource = TasksSafeEventSource;

  // Debug handle (optional)
  window.__mbhq_tasks_eventsource = () => singleton;
})();
