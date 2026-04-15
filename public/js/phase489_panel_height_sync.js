(() => {
  if (window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__) return;
  window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__ = true;

  const q = (s) => document.querySelector(s);

  function px(n) {
    return `${Math.max(0, Math.round(n))}px`;
  }

  function first() {
    for (const el of arguments) {
      if (el) return el;
    }
    return null;
  }

  function visible(el) {
    if (!el) return false;
    const cs = window.getComputedStyle(el);
    return !el.hasAttribute("hidden") && cs.display !== "none" && cs.visibility !== "hidden";
  }

  function outerHeight(el) {
    if (!el) return 0;
    const r = el.getBoundingClientRect();
    const cs = window.getComputedStyle(el);
    return Math.round(
      r.height +
      (parseFloat(cs.marginTop) || 0) +
      (parseFloat(cs.marginBottom) || 0)
    );
  }

  function lockHeight(el, h) {
    if (!el) return;
    el.style.height = px(h);
    el.style.minHeight = px(h);
    el.style.maxHeight = px(h);
    el.style.boxSizing = "border-box";
    el.style.minWidth = "0";
  }

  function setColumn(el) {
    if (!el) return;
    el.style.display = "flex";
    el.style.flexDirection = "column";
    el.style.minHeight = "0";
    el.style.overflow = "hidden";
    el.style.alignSelf = "stretch";
  }

  function setFill(el) {
    if (!el) return;
    el.style.flex = "1 1 auto";
    el.style.minHeight = "0";
    el.style.height = "100%";
    el.style.maxHeight = "100%";
    el.style.boxSizing = "border-box";
  }

  function syncOperatorPanels() {
    const operatorPanels = q("#operator-panels");
    const chatPanel = q("#op-panel-chat");
    const delegationPanel = q("#op-panel-delegation");

    if (!operatorPanels || !chatPanel || !delegationPanel) return;

    const activeOperatorPanel = first(
      visible(chatPanel) ? chatPanel : null,
      visible(delegationPanel) ? delegationPanel : null
    );

    if (!activeOperatorPanel) return;

    const targetHeight = outerHeight(activeOperatorPanel);
    if (!targetHeight || targetHeight < 100) return;

    operatorPanels.style.alignItems = "stretch";

    [chatPanel, delegationPanel].forEach((panel) => {
      lockHeight(panel, targetHeight);
      panel.style.flex = `0 0 ${px(targetHeight)}`;

      if (!visible(panel)) return;

      setColumn(panel);

      const card =
        panel.querySelector(":scope > section") ||
        panel.querySelector("section") ||
        panel;

      setFill(card);
      setColumn(card);
    });

    const delegationStatus = q("#delegation-status-panel");
    if (delegationStatus && visible(delegationPanel)) {
      delegationStatus.style.flex = "1 1 auto";
      delegationStatus.style.minHeight = "0";
      delegationStatus.style.height = "auto";
      delegationStatus.style.maxHeight = "none";
      delegationStatus.style.overflowY = "auto";
    }

    const delegationInput = q("#delegation-input") || q("#op-panel-delegation textarea");
    if (delegationInput && visible(delegationPanel)) {
      delegationInput.style.flex = "0 0 auto";
      delegationInput.style.height = "auto";
    }
  }

  function syncOuterWorkspaceCards() {
    const operatorCard = q("#operator-workspace-card");
    const telemetryCard = q("#observational-workspace-card");

    if (!operatorCard || !telemetryCard) return;

    const targetOuterHeight = outerHeight(operatorCard);
    if (!targetOuterHeight || targetOuterHeight < 100) return;

    lockHeight(telemetryCard, targetOuterHeight);
    telemetryCard.style.flex = `0 0 ${px(targetOuterHeight)}`;
    setColumn(telemetryCard);

    const telemetryChromeParts = [
      telemetryCard.querySelector(":scope > .flex.items-center.justify-between"),
      q("#observational-tabs")
    ].filter(Boolean);

    telemetryChromeParts.forEach((el) => {
      el.style.flex = "0 0 auto";
    });

    const observationalPanels = q("#observational-panels");
    if (observationalPanels) {
      observationalPanels.style.flex = "1 1 auto";
      observationalPanels.style.minHeight = "0";
      observationalPanels.style.overflow = "hidden";
      observationalPanels.style.display = "flex";
      observationalPanels.style.flexDirection = "column";
      observationalPanels.style.alignItems = "stretch";
    }
  }

  function syncTelemetryPanels() {
    const targetHeight = outerHeight(q("#op-panel-chat")) || outerHeight(q("#op-panel-delegation"));
    if (!targetHeight || targetHeight < 100) return;

    const telemetryPanels = [
      q("#obs-panel-recent"),
      q("#obs-panel-activity"),
      q("#obs-panel-events"),
    ].filter(Boolean);

    telemetryPanels.forEach((panel) => {
      lockHeight(panel, targetHeight);
      panel.style.flex = `0 0 ${px(targetHeight)}`;

      if (!visible(panel)) return;
      setColumn(panel);
      panel.style.margin = "0";
      panel.style.padding = "0";
    });

    const recentCard = q("#recent-tasks-card");
    const activityCard = q("#task-activity-card");
    const eventsCard = q("#task-events-card");

    [recentCard, activityCard, eventsCard].forEach((card) => {
      if (!card) return;
      card.style.margin = "0";
      setFill(card);
      setColumn(card);
    });

    const recentTasks = q("#recentTasks");
    const recentLogs = q("#recentLogs");
    const eventsAnchor = q("#mb-task-events-panel-anchor");
    const activityWrap = q("#task-activity-card > div");
    const activityCanvas = q("#task-activity-graph");

    [recentTasks, recentLogs, eventsAnchor].forEach((el) => {
      if (!el) return;
      el.style.flex = "1 1 auto";
      el.style.minHeight = "0";
      el.style.height = "100%";
      el.style.maxHeight = "100%";
      el.style.overflowY = "auto";
      el.style.boxSizing = "border-box";
    });

    if (activityWrap) {
      activityWrap.style.flex = "1 1 auto";
      activityWrap.style.minHeight = "0";
      activityWrap.style.height = "100%";
      activityWrap.style.maxHeight = "100%";
      activityWrap.style.display = "flex";
      activityWrap.style.flexDirection = "column";
      activityWrap.style.overflow = "hidden";
      activityWrap.style.boxSizing = "border-box";
      activityWrap.style.margin = "0";
    }

    if (activityCanvas) {
      activityCanvas.style.flex = "1 1 auto";
      activityCanvas.style.minHeight = "0";
      activityCanvas.style.height = "100%";
      activityCanvas.style.maxHeight = "100%";
      activityCanvas.style.display = "block";
      activityCanvas.style.boxSizing = "border-box";
    }
  }

  function sync() {
    syncOperatorPanels();
    syncOuterWorkspaceCards();
    syncTelemetryPanels();
  }

  function boot() {
    const rerun = () => requestAnimationFrame(sync);

    sync();

    window.addEventListener("resize", rerun);
    window.addEventListener("load", rerun);
    document.addEventListener("click", rerun);
    document.addEventListener("input", rerun);

    const operatorTabs = q("#operator-tabs");
    if (operatorTabs) operatorTabs.addEventListener("click", rerun);

    const observationalTabs = q("#observational-tabs");
    if (observationalTabs) observationalTabs.addEventListener("click", rerun);

    const mo = new MutationObserver(rerun);
    mo.observe(document.body, {
      subtree: true,
      childList: true,
      attributes: true
    });

    setInterval(sync, 1200);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
