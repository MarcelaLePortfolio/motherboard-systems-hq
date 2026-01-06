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
          window.__opsES = window.connectSSEWithBackoff({url:"/events/ops",isHealthyEvent:(n)=>n==="heartbeat"||n==="hello"||n==="ops.state",onState:(st)=>{try{if(window.__UI_DEBUG){console.log("[SSE:ops]",st);}}catch(_){}}});
      } catch (e) {
        console.error("[phase16 owner] FAILED creating window.__opsES:", e);

        console.warn("[phase16] failed to create ops EventSource", e);
        window.__opsES = null;
      }
    }

    
if (!(window.__refES && typeof window.__refES.addEventListener === "function")) {
      try {
        console.log("[phase16 owner] creating window.__refES...");
          window.__refES = window.connectSSEWithBackoff({url:"/events/reflections",isHealthyEvent:(n)=>n==="heartbeat"||n==="hello"||n==="reflections.state",onState:(st)=>{try{if(window.__UI_DEBUG){console.log("[SSE:ref]",st);}}catch(_){}}});
      
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

/* === Phase16 owner: dispatch + state cache (prevents snapshot race) === */
(() => {
  if (window.__PHASE16_OWNER_DISPATCH_BOUND) return;
  window.__PHASE16_OWNER_DISPATCH_BOUND = true;
  window.__PHASE16_SSE_OWNER_DISPATCHES = true;

  function safeJson(s) { try { return JSON.parse(s); } catch (_) { return null; } }

  function bindOps(es) {
    if (!es || typeof es.addEventListener !== "function") return;
    es.addEventListener("ops.state", (e) => {
      const obj = safeJson(e && e.data);
      if (!obj) return;
      window.__OPS_STATE = obj;
      window.dispatchEvent(new CustomEvent("ops.state", { detail: obj }));
    });
  }

  function bindReflections(es) {
    if (!es || typeof es.addEventListener !== "function") return;

    es.addEventListener("reflections.state", (e) => {
      const obj = safeJson(e && e.data);
      if (!obj) return;
      window.__REFLECTIONS_STATE = obj;
      window.dispatchEvent(new CustomEvent("reflections.state", { detail: obj }));
    });

    es.addEventListener("reflections.add", (e) => {
      const obj = safeJson(e && e.data);
      if (!obj) return;

      const item = obj.item || (obj.data && obj.data.item) || null;
      const cur = (window.__REFLECTIONS_STATE && typeof window.__REFLECTIONS_STATE === "object")
        ? window.__REFLECTIONS_STATE
        : { items: [], lastAt: null };

      if (item) {
        const items = Array.isArray(cur.items) ? cur.items.slice() : [];
        items.unshift(item);
        cur.items = items;
        cur.lastAt = item.ts != null ? item.ts : (cur.lastAt || null);
      }

      window.__REFLECTIONS_STATE = cur;
      window.dispatchEvent(new CustomEvent("reflections.state", { detail: cur }));
    });
  }

  // Bind to whatever the owner created (or later self-heals create)
  bindOps(window.__opsES);
  bindReflections(window.__refES);

  // If ES didn’t exist yet at append time, try a few times quickly.
  let tries = 0;
  const t = setInterval(() => {
    tries++;
    if (tries > 20) return clearInterval(t);
    if (window.__opsES) bindOps(window.__opsES);
    if (window.__refES) bindReflections(window.__refES);
  }, 100);
})();
