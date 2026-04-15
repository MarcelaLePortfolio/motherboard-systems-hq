(() => {
  if (window.__PHASE490_MEASURED_PANEL_HEIGHT_SYNC__) return;
  window.__PHASE490_MEASURED_PANEL_HEIGHT_SYNC__ = true;

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
    return Math.round(el.getBoundingClientRect().height);
  }

  function setExactHeight(el, h) {
    if (!el) return;
    el.style.height = `${h}px`;
    el.style.minHeight = `${h}px`;
    el.style.maxHeight = `${h}px`;
    el.style.boxSizing = "border-box";
  }

  function syncTelemetryToOperatorCard() {
    const operatorCard = q("#operator-workspace-card");
    const telemetryCard = q("#observational-workspace-card");
    const telemetryPanels = q("#observational-panels");

    if (!operatorCard || !telemetryCard || !telemetryPanels) return;

    const targetHeight = outerHeight(operatorCard);
    if (!targetHeight || targetHeight < 100) return;

    setExactHeight(telemetryCard, targetHeight);

    telemetryCard.style.display = "flex";
    telemetryCard.style.flexDirection = "column";
    telemetryCard.style.overflow = "hidden";

    telemetryPanels.style.flex = "1 1 auto";
    telemetryPanels.style.minHeight = "0";
    telemetryPanels.style.display = "flex";
    telemetryPanels.style.flexDirection = "column";
    telemetryPanels.style.overflow = "hidden";

    document.querySelectorAll("#observational-panels > .obs-panel").forEach((panel) => {
      if (!visible(panel)) return;
      panel.style.flex = "1 1 auto";
      panel.style.minHeight = "0";
      panel.style.display = "flex";
      panel.style.flexDirection = "column";
      panel.style.overflow = "hidden";
    });

    document.querySelectorAll("#recent-tasks-card, #task-activity-card, #task-events-card").forEach((card) => {
      if (!visible(card)) return;
      card.style.flex = "1 1 auto";
      card.style.minHeight = "0";
      card.style.height = "100%";
      card.style.maxHeight = "100%";
      card.style.display = "flex";
      card.style.flexDirection = "column";
      card.style.overflow = "hidden";
    });

    ["#recentTasks", "#recentLogs", "#mb-task-events-panel-anchor"].forEach((selector) => {
      const el = q(selector);
      if (!el) return;
      el.style.flex = "1 1 auto";
      el.style.minHeight = "0";
      el.style.overflowY = "auto";
    });

    const graphWrap = q("#task-activity-card > div");
    const graphCanvas = q("#task-activity-graph");

    if (graphWrap) {
      graphWrap.style.flex = "1 1 auto";
      graphWrap.style.minHeight = "0";
      graphWrap.style.height = "100%";
      graphWrap.style.display = "flex";
      graphWrap.style.overflow = "hidden";
    }

    if (graphCanvas) {
      graphCanvas.style.flex = "1 1 auto";
      graphCanvas.style.minHeight = "0";
      graphCanvas.style.height = "100%";
      graphCanvas.style.maxHeight = "100%";
    }
  }

  function boot() {
    const rerun = () => window.requestAnimationFrame(syncTelemetryToOperatorCard);

    syncTelemetryToOperatorCard();
    window.addEventListener("resize", rerun);
    window.addEventListener("load", rerun);
    document.addEventListener("click", rerun);

    const tabs = [q("#observational-tabs")].filter(Boolean);
    tabs.forEach((root) => root.addEventListener("click", rerun));

    const mo = new MutationObserver(rerun);
    mo.observe(document.body, {
      subtree: true,
      childList: true,
      attributes: true,
      attributeFilter: ["class", "style", "hidden", "aria-hidden"]
    });

    window.setInterval(syncTelemetryToOperatorCard, 1200);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
