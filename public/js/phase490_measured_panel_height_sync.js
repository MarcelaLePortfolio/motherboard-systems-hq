(() => {
  if (window.__PHASE490_MEASURED_PANEL_HEIGHT_SYNC__) return;
  window.__PHASE490_MEASURED_PANEL_HEIGHT_SYNC__ = true;

  function q(s) { return document.querySelector(s); }

  function visible(el) {
    if (!el) return false;
    const cs = window.getComputedStyle(el);
    return !el.hasAttribute("hidden") && cs.display !== "none" && cs.visibility !== "hidden";
  }

  function height(el) {
    return Math.round(el.getBoundingClientRect().height);
  }

  function findReference() {
    return [
      q("#delegation-card"),
      q("#chat-card")
    ].find(visible) || null;
  }

  function findTelemetryWrapper() {
    return q("#observational-workspace-card");
  }

  function sync() {
    const ref = findReference();
    const tele = findTelemetryWrapper();
    if (!ref || !tele) return;

    const target = height(ref);
    if (!target || target < 100) return;

    // 🔑 CRITICAL FIX:
    // Match the OUTER telemetry container, not the inner cards
    tele.style.height = target + "px";
    tele.style.minHeight = target + "px";
    tele.style.maxHeight = target + "px";
    tele.style.boxSizing = "border-box";
    tele.style.display = "flex";
    tele.style.flexDirection = "column";

    // Make inner panel fill exactly
    const panels = q("#observational-panels");
    if (panels) {
      panels.style.flex = "1 1 auto";
      panels.style.minHeight = "0";
      panels.style.display = "flex";
      panels.style.flexDirection = "column";
    }

    // Each tab panel fills container
    document.querySelectorAll(".obs-panel").forEach(p => {
      p.style.flex = "1 1 auto";
      p.style.minHeight = "0";
      p.style.display = "flex";
      p.style.flexDirection = "column";
    });

    // Inner cards fill panel
    document.querySelectorAll(
      "#recent-tasks-card, #task-activity-card, #task-events-card"
    ).forEach(card => {
      card.style.flex = "1 1 auto";
      card.style.minHeight = "0";
      card.style.height = "100%";
      card.style.maxHeight = "100%";
      card.style.display = "flex";
      card.style.flexDirection = "column";
    });

    // Scroll only inside content
    ["#recentTasks","#recentLogs","#mb-task-events-panel-anchor"].forEach(sel => {
      const el = q(sel);
      if (!el) return;
      el.style.flex = "1 1 auto";
      el.style.minHeight = "0";
      el.style.overflowY = "auto";
    });

    const graphWrap = q("#task-activity-card > div");
    const canvas = q("#task-activity-graph");

    if (graphWrap) {
      graphWrap.style.flex = "1 1 auto";
      graphWrap.style.minHeight = "0";
      graphWrap.style.display = "flex";
    }

    if (canvas) {
      canvas.style.flex = "1 1 auto";
      canvas.style.height = "100%";
    }

    console.log("[phase490] LOCKED OUTER TELEMETRY HEIGHT:", target);
  }

  function boot() {
    sync();
    const rerun = () => requestAnimationFrame(sync);

    window.addEventListener("resize", rerun);
    document.addEventListener("click", rerun);

    const mo = new MutationObserver(rerun);
    mo.observe(document.body, { subtree: true, childList: true, attributes: true });

    setInterval(sync, 1500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
