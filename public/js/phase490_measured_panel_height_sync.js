(() => {
  if (window.__PHASE490_MEASURED_PANEL_HEIGHT_SYNC__) return;
  window.__PHASE490_MEASURED_PANEL_HEIGHT_SYNC__ = true;

  const PANEL_SELECTORS = [
    "#op-panel-delegation",
    "#obs-panel-recent",
    "#obs-panel-activity",
    "#obs-panel-events",
    "#delegation-card",
    "#recent-tasks-card",
    "#task-activity-card",
    "#task-events-card"
  ];

  const INNER_SCROLL_SELECTORS = [
    "#delegation-status-panel",
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

  function findReferencePanel() {
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
  }

  function normalizeInnerLayout() {
    const delegationInput = document.querySelector("#delegation-input");
    if (delegationInput) {
      delegationInput.style.minHeight = "8rem";
      delegationInput.style.flex = "0 0 auto";
    }

    INNER_SCROLL_SELECTORS.forEach((selector) => {
      const el = document.querySelector(selector);
      if (!el) return;
      el.style.overflowY = "auto";
      el.style.minHeight = "0";
      el.style.flex = "1 1 auto";
    });

    const graphWrap = document.querySelector("#task-activity-card > div");
    const graphCanvas = document.querySelector("#task-activity-graph");
    if (graphWrap) {
      graphWrap.style.display = "flex";
      graphWrap.style.flex = "1 1 auto";
      graphWrap.style.minHeight = "0";
      graphWrap.style.overflow = "hidden";
    }
    if (graphCanvas) {
      graphCanvas.style.flex = "1 1 auto";
      graphCanvas.style.height = "100%";
      graphCanvas.style.maxHeight = "100%";
      graphCanvas.style.minHeight = "0";
    }
  }

  function sync() {
    const ref = findReferencePanel();
    if (!ref) return;

    const h = ref.getBoundingClientRect().height;
    if (!h || h < 50) return;

    document.documentElement.style.setProperty("--phase490-measured-chat-panel-height", px(h));

    PANEL_SELECTORS.forEach((selector) => {
      document.querySelectorAll(selector).forEach((el) => applyHeight(el, h));
    });

    normalizeInnerLayout();

    try {
      console.log("[phase490] measured Matilda panel height:", Math.round(h));
    } catch (_) {}
  }

  function boot() {
    sync();

    const rerun = () => window.requestAnimationFrame(sync);
    window.addEventListener("resize", rerun);
    window.addEventListener("load", rerun);
    document.addEventListener("click", rerun);
    document.addEventListener("input", rerun);

    const mo = new MutationObserver(rerun);
    mo.observe(document.body, {
      subtree: true,
      childList: true,
      attributes: true,
      attributeFilter: ["class", "style", "hidden", "aria-hidden"]
    });

    window.setInterval(sync, 1200);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
