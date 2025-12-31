/**
 * Phase 16: Owner script that creates OPS + Reflections EventSource handles on window.
 * Goal: ensure window.__opsES / window.__refES exist BEFORE any dashboard status code
 * attempts to assign .onopen/.onmessage/etc, and avoid null/ordering crashes.
 */
(() => {
  // Don't double-start (hot reload / duplicate script tag)
  if (window.__PHASE16_SSE_OWNER_STARTED) return;
  window.__PHASE16_SSE_OWNER_STARTED = true;

  
  console.log("[phase16 owner] start: __refES=", window.__refES);
function boot() {
    // If the dashboard page isn't actually present, don't create SSE.
    const hasDashboardRoot =
      document.querySelector("#dashboard-root") ||
      document.querySelector("[data-dashboard]") ||
      document.querySelector("main.dashboard") ||
      document.querySelector("body.dashboard");

    
// PHASE16_OWNER_WAIT_FOR_DASHBOARD
  const _p16_start = Date.now();
  (function _p16_waitForDashboard(){
    const ok = !!(document.getElementById("phase16_reflections_status") ||
                  document.getElementById("phase16_reflections_log") ||
                  document.querySelector("main") ||
                  document.body);
    if (!ok) {
      if (Date.now() - _p16_start < 2000) return setTimeout(_p16_waitForDashboard, 50);
      console.warn("[phase16 owner] dashboard root not found after 2s; continuing anyway");
    }
  })();
// Create once, reuse forever.
    if (!window.__opsES) {
      try {
        window.__opsES = new EventSource("/events/ops");
      } catch (e) {
        console.error("[phase16 owner] FAILED creating window.__opsES:", e);

        console.warn("[phase16] failed to create ops EventSource", e);
        window.__opsES = null;
      }
    }

    
if (!(window.__refES && typeof window.__refES.addEventListener === "function")) {
      try {
        console.log("[phase16 owner] creating window.__refES...");
        window.__refES = new EventSource("/events/reflections");
      
        console.log("[phase16 owner] created window.__refES", window.__refES, "readyState=", window.__refES && window.__refES.readyState);
} catch (e) {
        console.error("[phase16 owner] FAILED creating window.__opsES:", e);

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
