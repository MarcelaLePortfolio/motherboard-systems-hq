(() => {
  if (window.__PHASE490_MEASURED_PANEL_HEIGHT_SYNC__) return;
  window.__PHASE490_MEASURED_PANEL_HEIGHT_SYNC__ = true;

  const TELEMETRY_CARDS = [
    "#recent-tasks-card",
    "#task-activity-card",
    "#task-events-card"
  ];

  const SCROLL_AREAS = [
    "#recentTasks",
    "#recentLogs",
    "#mb-task-events-panel-anchor"
  ];

  function px(n) {
    return `${Math.max(0, Math.round(n))}px`;
  }

  function visible(el) {
    if (!el) return false;
    const cs = window.getComputedStyle(el);
    return !el.hasAttribute("hidden") && cs.display !== "none" && cs.visibility !== "hidden";
  }

  function findMatildaPanel() {
    const candidates = [
      document.querySelector("#op-panel-chat"),
      document.querySelector('[data-workspace-panel][aria-labelledby="op-tab-chat"]'),
      document.querySelector("#operator-panels > :not([hidden])")
    ].filter(Boolean);

    return candidates.find(visible) || null;
  }

  function applyHeight(el, h) {
    if (!el) return;
    el.style.height = px(h);
    el.style.minHeight = px(h);
    el.style.maxHeight = px(h);
    el.style.boxSizing = "border-box";
    el.style.display = "flex";
    el.style.flexDirection = "column";
  }

  function normalizeInner() {
    SCROLL_AREAS.forEach(sel => {
      const el = document.querySelector(sel);
      if (!el) return;
      el.style.flex = "1 1 auto";
      el.style.minHeight = "0";
      el.style.overflowY = "auto";
    });

    const graphWrap = document.querySelector("#task-activity-card > div");
    const canvas = document.querySelector("#task-activity-graph");

    if (graphWrap) {
      graphWrap.style.flex = "1 1 auto";
      graphWrap.style.minHeight = "0";
      graphWrap.style.display = "flex";
    }

    if (canvas) {
      canvas.style.flex = "1 1 auto";
      canvas.style.height = "100%";
    }
  }

  function sync() {
    const ref = findMatildaPanel();
    if (!ref) return;

    const h = ref.getBoundingClientRect().height;
    if (!h || h < 100) return;

    TELEMETRY_CARDS.forEach(sel => {
      document.querySelectorAll(sel).forEach(el => applyHeight(el, h));
    });

    normalizeInner();

    console.log("[phase490] synced telemetry cards to:", Math.round(h));
  }

  function boot() {
    sync();

    const rerun = () => requestAnimationFrame(sync);

    window.addEventListener("resize", rerun);
    document.addEventListener("click", rerun);
    document.addEventListener("input", rerun);

    const mo = new MutationObserver(rerun);
    mo.observe(document.body, {
      subtree: true,
      childList: true,
      attributes: true,
      attributeFilter: ["class", "style", "hidden"]
    });

    setInterval(sync, 1500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
