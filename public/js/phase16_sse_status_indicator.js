(() => {
  if (typeof window.__UI_DEBUG === "undefined") window.__UI_DEBUG = false;

  const qs = (s) => document.querySelector(s);

  function hideDupes() {
    const selectors = [
      "#ops-sse-status",
      "#ref-sse-status",
      ".ops-sse-status",
      ".ref-sse-status",
      "[data-ops-sse]",
      "[data-ref-sse]",
      "[data-sse-status]",
      "[data-sse-indicator]",
      "#phase16-debug-hud",
      "#phase16-owner-waiting",
      "#phase16-consumer-waiting",
    ];
    selectors.forEach((sel) => {
      document.querySelectorAll(sel).forEach((el) => {
        if (el && el.id === "phase16-sse-indicator") return;
        el.style.display = "none";
      });
    });
  }

  function aggregate(ops, ref) {
    const opsOpen = ops === 1, refOpen = ref === 1;
    if (opsOpen && refOpen) return ["SSE: OK", "ok"];
    if (opsOpen || refOpen) return ["SSE: DEGRADED", "warn"];
    if (ops === 0 || ref === 0) return ["SSE: CONNECTING", "info"];
    return ["SSE: DOWN", "bad"];
  }

  function applyMode(el, mode) {
    const styles = {
      ok:   "padding:4px 8px;border-radius:9999px;border:1px solid rgba(40,200,120,.35);background:rgba(40,200,120,.10);backdrop-filter:blur(6px)",
      warn: "padding:4px 8px;border-radius:9999px;border:1px solid rgba(255,200,80,.35);background:rgba(255,200,80,.10);backdrop-filter:blur(6px)",
      info: "padding:4px 8px;border-radius:9999px;border:1px solid rgba(160,180,255,.35);background:rgba(160,180,255,.10);backdrop-filter:blur(6px)",
      bad:  "padding:4px 8px;border-radius:9999px;border:1px solid rgba(255,90,90,.35);background:rgba(255,90,90,.10);backdrop-filter:blur(6px)",
    };
    el.setAttribute("style", styles[mode] || styles.info);
  }

  function tick() {
    hideDupes();

    const pill = qs("#phase16-sse-indicator-text");
    if (!pill) return;

    const ops = window.__opsES?.readyState;
    const ref = window.__refES?.readyState;

    const [label, mode] = aggregate(ops, ref);
    pill.textContent = label;
    applyMode(pill, mode);

    if (window.__UI_DEBUG) {
      const s = (x) => (x === 1 ? "OPEN" : x === 0 ? "CONNECTING" : x === 2 ? "CLOSED" : "…");
      pill.textContent = `${label} (ops:${s(ops)}, ref:${s(ref)})`;
    }
  }

  function boot() {
    tick();
    setInterval(tick, 350);
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot);
  else boot();
})();
