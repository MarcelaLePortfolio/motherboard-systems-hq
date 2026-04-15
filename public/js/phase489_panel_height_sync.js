(() => {
  if (window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__) return;
  window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__ = true;

  function px(n) {
    return `${Math.max(0, Math.round(n))}px`;
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

  function ensureProbe() {
    let probe = byId("phase489-height-probe");
    if (probe) return probe;

    probe = document.createElement("pre");
    probe.id = "phase489-height-probe";
    probe.style.position = "fixed";
    probe.style.right = "12px";
    probe.style.bottom = "12px";
    probe.style.zIndex = "99999";
    probe.style.margin = "0";
    probe.style.padding = "10px 12px";
    probe.style.maxWidth = "320px";
    probe.style.background = "rgba(2,6,23,0.92)";
    probe.style.color = "#e2e8f0";
    probe.style.border = "1px solid rgba(71,85,105,0.95)";
    probe.style.borderRadius = "12px";
    probe.style.fontSize = "11px";
    probe.style.lineHeight = "1.35";
    probe.style.fontFamily = "ui-monospace, SFMono-Regular, Menlo, monospace";
    probe.style.whiteSpace = "pre-wrap";
    probe.style.pointerEvents = "none";
    probe.style.boxShadow = "0 10px 30px rgba(0,0,0,0.35)";
    document.body.appendChild(probe);
    return probe;
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
    if (total > 0) return { total, pieces: included };
    if (pieces.transcript) return { total: rectHeight(pieces.transcript), pieces: [{ name: "transcript", h: rectHeight(pieces.transcript) }] };
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

  function renderProbe(targetHeight, targets, pieces) {
    const probe = ensureProbe();
    probe.textContent = [
      "PHASE489 HEIGHT PROBE",
      `target: ${targetHeight}`,
      `delegation: ${rectHeight(targets.delegationCard)}`,
      `recent: ${rectHeight(targets.recentTasksCard)}`,
      `activity: ${rectHeight(targets.taskActivityCard)}`,
      `events: ${rectHeight(targets.taskEventsCard)}`,
      "",
      "pieces:",
      ...pieces.map((p) => `${p.name}: ${p.h}`)
    ].join("\n");
  }

  function syncPanelHeights() {
    const reference = computeReferenceHeight();
    if (!reference) return;

    const targetHeight = reference.total;
    const targets = findTargetPanels();

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

    renderProbe(targetHeight, targets, reference.pieces);
  }

  function boot() {
    syncPanelHeights();
    window.addEventListener("resize", syncPanelHeights);
    window.addEventListener("load", syncPanelHeights);
    document.addEventListener("click", () => window.requestAnimationFrame(syncPanelHeights));

    const obsTabs = byId("observational-tabs");
    const opTabs = byId("operator-tabs");
    [obsTabs, opTabs].filter(Boolean).forEach((root) => {
      root.addEventListener("click", () => {
        window.requestAnimationFrame(syncPanelHeights);
      });
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
