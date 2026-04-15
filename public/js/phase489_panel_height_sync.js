(() => {
  if (window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__) return;
  window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__ = true;

  function px(n) {
    return `${Math.max(0, Math.round(n))}px`;
  }

  function log() {
    try { console.log("[phase489-panel-height-sync]", ...arguments); } catch (_) {}
  }

  function byId(id) {
    return document.getElementById(id);
  }

  function first() {
    for (const el of arguments) if (el) return el;
    return null;
  }

  function rectHeight(el) {
    if (!el) return 0;
    const r = el.getBoundingClientRect();
    return Math.round(r.height || 0);
  }

  function visible(el) {
    if (!el) return false;
    const cs = window.getComputedStyle(el);
    return !el.hasAttribute("hidden") && cs.display !== "none" && cs.visibility !== "hidden";
  }

  function findChatPieces() {
    const transcript = first(
      byId("matilda-chat-transcript"),
      document.querySelector("#op-panel-chat #matilda-chat-transcript"),
      document.querySelector("#operator-workspace-card #matilda-chat-transcript")
    );

    const guidance = first(
      byId("operator-guidance-panel"),
      document.querySelector("#op-panel-chat #operator-guidance-panel")
    );

    const helper = first(
      byId("matilda-helper-text-ops"),
      byId("matilda-chat-helper"),
      document.querySelector("#op-panel-chat .text-xs.text-gray-400")
    );

    const inputRow = first(
      document.querySelector("#op-panel-chat .flex.flex-col.md\\:flex-row.md\\:items-center.md\\:justify-between.gap-3"),
      document.querySelector("#op-panel-chat .gap-3"),
      document.querySelector("#op-panel-chat textarea")?.closest("div")
    );

    const textarea = first(
      byId("matilda-input"),
      byId("matilda-chat-input"),
      document.querySelector("#op-panel-chat textarea")
    );

    return { transcript, guidance, helper, inputRow, textarea };
  }

  function findTargetPanels() {
    return {
      delegationCard: first(byId("delegation-card"), document.querySelector("#op-panel-delegation section")),
      recentTasksCard: byId("recent-tasks-card"),
      taskActivityCard: byId("task-activity-card"),
      taskEventsCard: byId("task-events-card"),
      delegationStatus: byId("delegation-status-panel"),
      delegationInput: first(byId("delegation-input"), document.querySelector("#op-panel-delegation textarea")),
      recentTasks: first(byId("recentTasks"), document.querySelector('[data-phase61-list="recent"]')),
      recentLogs: byId("recentLogs"),
      events: byId("mb-task-events-panel-anchor"),
      activityWrap: document.querySelector("#task-activity-card > div"),
      activityCanvas: byId("task-activity-graph"),
    };
  }

  function computeReferenceHeight() {
    const pieces = findChatPieces();
    const included = Object.entries(pieces)
      .filter(([, el]) => el && visible(el))
      .map(([name, el]) => ({ name, h: rectHeight(el) }));

    const total = included.reduce((sum, item) => sum + item.h, 0);
    log("reference pieces", included, "total", total);

    if (total > 0) return total;
    if (pieces.transcript) return rectHeight(pieces.transcript);
    return null;
  }

  function applyPanelHeight(panel, height) {
    if (!panel) return;
    panel.style.height = px(height);
    panel.style.minHeight = px(height);
    panel.style.maxHeight = px(height);
    panel.style.display = "flex";
    panel.style.flexDirection = "column";
    panel.style.overflow = "hidden";
    panel.style.boxSizing = "border-box";
  }

  function applyInnerFill(el, scroll) {
    if (!el) return;
    el.style.flex = "1 1 auto";
    el.style.minHeight = "0";
    if (scroll) el.style.overflowY = "auto";
  }

  function syncPanelHeights() {
    const targetHeight = computeReferenceHeight();
    if (!targetHeight) {
      log("no target height resolved");
      return;
    }

    const targets = findTargetPanels();
    log("targets", Object.fromEntries(Object.entries(targets).map(([k, v]) => [k, !!v])));

    [
      targets.delegationCard,
      targets.recentTasksCard,
      targets.taskActivityCard,
      targets.taskEventsCard,
    ].forEach((panel) => applyPanelHeight(panel, targetHeight));

    [targets.recentTasks, targets.recentLogs, targets.events, targets.delegationStatus].forEach((el) => {
      applyInnerFill(el, true);
    });

    if (targets.delegationInput) {
      targets.delegationInput.style.flex = "1 1 auto";
      targets.delegationInput.style.minHeight = "0";
      targets.delegationInput.style.height = "100%";
    }

    if (targets.activityWrap) {
      targets.activityWrap.style.flex = "1 1 auto";
      targets.activityWrap.style.minHeight = "0";
      targets.activityWrap.style.height = "100%";
      targets.activityWrap.style.display = "flex";
      targets.activityWrap.style.overflow = "hidden";
    }

    if (targets.activityCanvas) {
      targets.activityCanvas.style.flex = "1 1 auto";
      targets.activityCanvas.style.minHeight = "0";
      targets.activityCanvas.style.height = "100%";
      targets.activityCanvas.style.maxHeight = "100%";
    }

    [byId("obs-panel-recent"), byId("obs-panel-activity"), byId("obs-panel-events"), byId("op-panel-delegation")]
      .filter(Boolean)
      .forEach((panel) => {
        panel.style.minHeight = "0";
        panel.style.height = "auto";
      });

    log("applied targetHeight", targetHeight, {
      delegationCard: rectHeight(targets.delegationCard),
      recentTasksCard: rectHeight(targets.recentTasksCard),
      taskActivityCard: rectHeight(targets.taskActivityCard),
      taskEventsCard: rectHeight(targets.taskEventsCard),
    });
  }

  function boot() {
    syncPanelHeights();
    window.addEventListener("resize", syncPanelHeights);
    window.addEventListener("load", syncPanelHeights);
    document.addEventListener("click", () => window.requestAnimationFrame(syncPanelHeights));

    const obsTabs = byId("observational-tabs");
    const opTabs = byId("operator-tabs");
    [obsTabs, opTabs].filter(Boolean).forEach((root) => {
      root.addEventListener("click", () => window.requestAnimationFrame(syncPanelHeights));
    });

    const mo = new MutationObserver(() => window.requestAnimationFrame(syncPanelHeights));
    mo.observe(document.body, { subtree: true, childList: true, attributes: true });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
