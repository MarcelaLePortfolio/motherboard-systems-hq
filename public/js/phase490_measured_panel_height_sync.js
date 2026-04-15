(() => {
  if (window.__PHASE490_MEASURED_PANEL_HEIGHT_SYNC__) return;
  window.__PHASE490_MEASURED_PANEL_HEIGHT_SYNC__ = true;

  function px(n) {
    return `${Math.max(0, Math.round(n))}px`;
  }

  function visible(el) {
    if (!el) return false;
    const cs = window.getComputedStyle(el);
    return !el.hasAttribute("hidden") && cs.display !== "none" && cs.visibility !== "hidden";
  }

  function q(selector) {
    return document.querySelector(selector);
  }

  function qa(selector) {
    return Array.from(document.querySelectorAll(selector));
  }

  function setExactHeight(el, h) {
    if (!el) return;
    el.style.height = px(h);
    el.style.minHeight = px(h);
    el.style.maxHeight = px(h);
    el.style.boxSizing = "border-box";
  }

  function setFill(el) {
    if (!el) return;
    el.style.display = "flex";
    el.style.flexDirection = "column";
    el.style.flex = "1 1 auto";
    el.style.minHeight = "0";
  }

  function findReferencePanel() {
    return (
      q("#op-panel-chat") ||
      q('[data-workspace-panel][aria-labelledby="op-tab-chat"]') ||
      q("#operator-panels > :not([hidden])")
    );
  }

  function syncOperatorPanels(targetHeight) {
    const operatorContainers = [
      q("#op-panel-chat"),
      q("#op-panel-delegation"),
      q("#chat-card"),
      q("#delegation-card")
    ];

    operatorContainers.forEach((el) => {
      if (!el) return;
      setFill(el);
      setExactHeight(el, targetHeight);
    });

    const delegationStatus = q("#delegation-status-panel");
    if (delegationStatus) {
      delegationStatus.style.overflowY = "auto";
      delegationStatus.style.flex = "1 1 auto";
      delegationStatus.style.minHeight = "0";
    }

    const delegationInput = q("#delegation-input");
    if (delegationInput) {
      delegationInput.style.flex = "0 0 auto";
      delegationInput.style.minHeight = "8rem";
    }
  }

  function syncTelemetryPanels(targetHeight) {
    const workspaceCard = q("#observational-workspace-card");
    const panelsRoot = q("#observational-panels");
    const activePanel =
      qa("#observational-panels > .obs-panel").find(visible) ||
      q("#obs-panel-recent");

    [workspaceCard, panelsRoot, activePanel].forEach((el) => {
      if (!el) return;
      setFill(el);
      setExactHeight(el, targetHeight);
    });

    const telemetryCards = [
      q("#recent-tasks-card"),
      q("#task-activity-card"),
      q("#task-events-card")
    ];

    telemetryCards.forEach((el) => {
      if (!el) return;
      setFill(el);
      setExactHeight(el, targetHeight);
    });

    const recentTasks = q("#recentTasks");
    const recentLogs = q("#recentLogs");
    const taskEvents = q("#mb-task-events-panel-anchor");

    [recentTasks, recentLogs, taskEvents].forEach((el) => {
      if (!el) return;
      el.style.flex = "1 1 auto";
      el.style.minHeight = "0";
      el.style.overflowY = "auto";
    });

    const activityWrap = q("#task-activity-card > div");
    const activityCanvas = q("#task-activity-graph");

    if (activityWrap) {
      setFill(activityWrap);
      setExactHeight(activityWrap, targetHeight);
      activityWrap.style.overflow = "hidden";
    }

    if (activityCanvas) {
      activityCanvas.style.flex = "1 1 auto";
      activityCanvas.style.minHeight = "0";
      activityCanvas.style.height = "100%";
      activityCanvas.style.maxHeight = "100%";
    }
  }

  function sync() {
    const ref = findReferencePanel();
    if (!ref || !visible(ref)) return;

    const targetHeight = ref.getBoundingClientRect().height;
    if (!targetHeight || targetHeight < 100) return;

    document.documentElement.style.setProperty("--phase490-measured-chat-panel-height", px(targetHeight));

    syncOperatorPanels(targetHeight);
    syncTelemetryPanels(targetHeight);

    try {
      console.log("[phase490] synced exact panel height:", Math.round(targetHeight));
    } catch (_) {}
  }

  function boot() {
    const rerun = () => window.requestAnimationFrame(sync);

    sync();
    window.addEventListener("resize", rerun);
    window.addEventListener("load", rerun);
    document.addEventListener("click", rerun);
    document.addEventListener("input", rerun);

    const tabRoots = [q("#operator-tabs"), q("#observational-tabs")].filter(Boolean);
    tabRoots.forEach((root) => root.addEventListener("click", rerun));

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
