/**
 * Phase 16: Owner script that creates OPS + Reflections EventSource handles on window.
 * Goal: ensure window.__opsES / window.__refES exist BEFORE any dashboard status code
 * attempts to assign .onopen/.onmessage/etc, and avoid null/ordering crashes.
 */
(() => {
  // Don't double-start (hot reload / duplicate script tag)
  if (window.__PHASE16_SSE_OWNER_STARTED) return;
  window.__PHASE16_SSE_OWNER_STARTED = true;

  function boot() {
    // If the dashboard page isn't actually present, don't create SSE.
    const hasDashboardRoot =
      document.querySelector("#dashboard-root") ||
      document.querySelector("[data-dashboard]") ||
      document.querySelector("main.dashboard") ||
      document.querySelector("body.dashboard");

    if (!hasDashboardRoot) return;

    // Create once, reuse forever.
    if (!window.__opsES) {
      try {
        window.__opsES = new EventSource("/events/ops");
      } catch (e) {
        console.warn("[phase16] failed to create ops EventSource", e);
        window.__opsES = null;
      }
    }

    if (!window.__refES) {
      try {
        window.__refES = new EventSource("/events/reflections");
      } catch (e) {
        console.warn("[phase16] failed to create reflections EventSource", e);
        window.__refES = null;
      }
    }

    window.__PHASE16_SSE_OWNER_READY = true;
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
