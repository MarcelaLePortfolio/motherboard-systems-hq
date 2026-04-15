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

  function q(selector) {
    return document.querySelector(selector);
  }

  function visible(el) {
    if (!el) return false;
    const cs = window.getComputedStyle(el);
    return !el.hasAttribute("hidden") && cs.display !== "none" && cs.visibility !== "hidden";
  }

  function outerHeight(el) {
    if (!el) return 0;
    const rect = el.getBoundingClientRect();
    const cs = window.getComputedStyle(el);
    const mt = parseFloat(cs.marginTop || "0") || 0;
    const mb = parseFloat(cs.marginBottom || "0") || 0;
    return rect.height + mt + mb;
  }

  function findReferenceCard() {
    const candidates = [
      q("#chat-card"),
      q("#op-panel-chat #chat-card"),
      q("#matilda-chat-transcript")?.closest("section"),
      q("#op-panel-chat")
    ].filter(Boolean);

    return candidates.find(visible) || null;
  }

  function applyExactHeight(el, h) {
    if (!el) return;
    el.style.height = px(h);
    el.style.minHeight = px(h);
    el.style.maxHeight = px(h);
    el.style.boxSizing = "border-box";
    el.style.display = "flex";
    el.style.flexDirection = "column";
    el.style.flex = "0 0 auto";
  }

  function normalizeInnerRegions() {
    SCROLL_AREAS.forEach((sel) => {
      const el = q(sel);
      if (!el) return;
      el.style.flex = "1 1 auto";
      el.style.minHeight = "0";
      el.style.overflowY = "auto";
    });

    const graphWrap = q("#task-activity-card > div");
    const canvas = q("#task-activity-graph");

    if (graphWrap) {
      graphWrap.style.display = "flex";
      graphWrap.style.flex = "1 1 auto";
      graphWrap.style.minHeight = "0";
      graphWrap.style.height = "100%";
      graphWrap.style.maxHeight = "100%";
      graphWrap.style.overflow = "hidden";
    }

    if (canvas) {
      canvas.style.flex = "1 1 auto";
      canvas.style.minHeight = "0";
      canvas.style.height = "100%";
      canvas.style.maxHeight = "100%";
    }
  }

  function sync() {
    const ref = findReferenceCard();
    if (!ref) return;

    const targetHeight = outerHeight(ref);
    if (!targetHeight || targetHeight < 100) return;

    TELEMETRY_CARDS.forEach((sel) => {
      document.querySelectorAll(sel).forEach((el) => applyExactHeight(el, targetHeight));
    });

    normalizeInnerRegions();

    console.log("[phase490] synced telemetry cards to chat-card outer height:", Math.round(targetHeight));
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

    window.setInterval(sync, 1500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
