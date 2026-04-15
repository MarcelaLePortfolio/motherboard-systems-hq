(() => {
  if (window.__PHASE490_HEIGHT_DIAGNOSTIC_ACTIVE__) return;
  window.__PHASE490_HEIGHT_DIAGNOSTIC_ACTIVE__ = true;

  function byId(id) {
    return document.getElementById(id);
  }

  function visible(el) {
    if (!el) return false;
    const style = window.getComputedStyle(el);
    return !el.hasAttribute("hidden") && style.display !== "none" && style.visibility !== "hidden";
  }

  function h(el) {
    return el ? Math.round(el.getBoundingClientRect().height) : 0;
  }

  function activeTelemetryPanel() {
    return [
      byId("recent-tasks-card"),
      byId("task-activity-card"),
      byId("task-events-card"),
    ].find(visible) || null;
  }

  function ensureOverlay() {
    let el = byId("phase490-height-diagnostic-overlay");
    if (el) return el;

    el = document.createElement("pre");
    el.id = "phase490-height-diagnostic-overlay";
    Object.assign(el.style, {
      position: "fixed",
      right: "12px",
      bottom: "12px",
      zIndex: "99999",
      margin: "0",
      padding: "10px 12px",
      maxWidth: "360px",
      background: "rgba(2, 6, 23, 0.92)",
      color: "#e2e8f0",
      border: "1px solid rgba(71, 85, 105, 0.95)",
      borderRadius: "12px",
      fontSize: "11px",
      lineHeight: "1.4",
      fontFamily: "ui-monospace, SFMono-Regular, Menlo, monospace",
      whiteSpace: "pre-wrap",
      pointerEvents: "none",
      boxShadow: "0 10px 30px rgba(0,0,0,0.35)"
    });
    document.body.appendChild(el);
    return el;
  }

  function render() {
    const overlay = ensureOverlay();

    const lines = [
      "PHASE 490 HEIGHT DIAGNOSTIC",
      "",
      `operator-workspace-card: ${h(byId("operator-workspace-card"))}`,
      `observational-workspace-card: ${h(byId("observational-workspace-card"))}`,
      `chat-card: ${h(byId("chat-card"))}`,
      `delegation-card: ${h(byId("delegation-card"))}`,
      `recent-tasks-card: ${h(byId("recent-tasks-card"))}`,
      `task-activity-card: ${h(byId("task-activity-card"))}`,
      `task-events-card: ${h(byId("task-events-card"))}`,
      "",
      `operator visible: ${visible(byId("chat-card")) ? "chat" : visible(byId("delegation-card")) ? "delegation" : "unknown"}`,
      `telemetry visible: ${
        visible(byId("recent-tasks-card")) ? "recent" :
        visible(byId("task-activity-card")) ? "activity" :
        visible(byId("task-events-card")) ? "events" : "unknown"
      }`,
      "",
      `matilda-chat-transcript: ${h(byId("matilda-chat-transcript"))}`,
      `delegation-status-panel: ${h(byId("delegation-status-panel"))}`,
      `recentTasks: ${h(byId("recentTasks"))}`,
      `recentLogs: ${h(byId("recentLogs"))}`,
      `mb-task-events-panel-anchor: ${h(byId("mb-task-events-panel-anchor"))}`,
      `task-activity-graph: ${h(byId("task-activity-graph"))}`
    ];

    overlay.textContent = lines.join("\n");
  }

  function boot() {
    render();
    window.addEventListener("resize", render);
    document.addEventListener("click", () => requestAnimationFrame(render));
    const mo = new MutationObserver(() => requestAnimationFrame(render));
    mo.observe(document.body, {
      subtree: true,
      childList: true,
      attributes: true,
      attributeFilter: ["class", "style", "hidden", "aria-hidden"]
    });
    setInterval(render, 1000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
