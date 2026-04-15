(() => {
  if (window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__) return;
  window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__ = true;

  function px(n) {
    return `${Math.max(0, Math.round(n))}px`;
  }

  function findChatReferenceHeight() {
    const transcript =
      document.getElementById("matilda-chat-transcript") ||
      document.querySelector("#op-panel-chat #matilda-chat-transcript") ||
      document.querySelector("#op-panel-chat .bg-gray-900.border.border-gray-700.rounded-xl.p-4.flex-1") ||
      document.querySelector("#operator-workspace-card #op-panel-chat .flex-1");

    const guidance = document.getElementById("operator-guidance-panel");
    const helper = document.getElementById("matilda-helper-text-ops");
    const inputRow =
      document.querySelector("#op-panel-chat .flex.flex-col.md\\:flex-row.md\\:items-center.md\\:justify-between.gap-3") ||
      document.querySelector("#op-panel-chat .gap-3");
    const textarea = document.getElementById("matilda-input");

    if (!transcript) return null;

    const pieces = [transcript, guidance, helper, inputRow, textarea].filter(Boolean);
    const total = pieces.reduce((sum, el) => sum + el.getBoundingClientRect().height, 0);

    return total > 0 ? total : transcript.getBoundingClientRect().height;
  }

  function syncPanelHeights() {
    const targetHeight = findChatReferenceHeight();
    if (!targetHeight) return;

    const telemetryPanels = [
      document.getElementById("recent-tasks-card"),
      document.getElementById("task-activity-card"),
      document.getElementById("task-events-card"),
      document.getElementById("delegation-card"),
    ].filter(Boolean);

    telemetryPanels.forEach((panel) => {
      panel.style.height = px(targetHeight);
      panel.style.minHeight = px(targetHeight);
      panel.style.maxHeight = px(targetHeight);
      panel.style.display = "flex";
      panel.style.flexDirection = "column";
      panel.style.overflow = "hidden";
    });

    const recentTasks = document.getElementById("recentTasks");
    const recentLogs = document.getElementById("recentLogs");
    const events = document.getElementById("mb-task-events-panel-anchor");
    const activityWrap = document.querySelector("#task-activity-card > div");
    const activityCanvas = document.getElementById("task-activity-graph");
    const delegationStatus = document.getElementById("delegation-status-panel");
    const delegationTextarea = document.getElementById("delegation-input");

    [recentTasks, recentLogs, events, delegationStatus].filter(Boolean).forEach((el) => {
      el.style.flex = "1 1 auto";
      el.style.minHeight = "0";
      el.style.overflowY = "auto";
    });

    if (delegationTextarea) {
      delegationTextarea.style.flex = "1 1 auto";
      delegationTextarea.style.minHeight = "0";
      delegationTextarea.style.height = "100%";
    }

    if (activityWrap) {
      activityWrap.style.flex = "1 1 auto";
      activityWrap.style.minHeight = "0";
      activityWrap.style.height = "100%";
      activityWrap.style.display = "flex";
    }

    if (activityCanvas) {
      activityCanvas.style.flex = "1 1 auto";
      activityCanvas.style.minHeight = "0";
      activityCanvas.style.height = "100%";
      activityCanvas.style.maxHeight = "100%";
    }

    const panels = [
      document.getElementById("obs-panel-recent"),
      document.getElementById("obs-panel-activity"),
      document.getElementById("obs-panel-events"),
      document.getElementById("op-panel-delegation"),
    ].filter(Boolean);

    panels.forEach((panel) => {
      panel.style.minHeight = "0";
      panel.style.height = "auto";
    });
  }

  function boot() {
    syncPanelHeights();
    window.addEventListener("resize", syncPanelHeights);
    window.addEventListener("load", syncPanelHeights);
    document.addEventListener("click", () => {
      window.requestAnimationFrame(syncPanelHeights);
    });

    const obsTabs = document.getElementById("observational-tabs");
    const opTabs = document.getElementById("operator-tabs");
    [obsTabs, opTabs].filter(Boolean).forEach((root) => {
      root.addEventListener("click", () => {
        window.requestAnimationFrame(syncPanelHeights);
      });
    });

    const mo = new MutationObserver(() => {
      window.requestAnimationFrame(syncPanelHeights);
    });
    mo.observe(document.body, { subtree: true, childList: true, attributes: true });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
