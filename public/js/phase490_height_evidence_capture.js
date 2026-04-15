(() => {
  if (window.__PHASE490_HEIGHT_EVIDENCE_CAPTURE__) return;
  window.__PHASE490_HEIGHT_EVIDENCE_CAPTURE__ = true;

  function q(sel) {
    return document.querySelector(sel);
  }

  function visible(el) {
    if (!el) return false;
    const cs = window.getComputedStyle(el);
    return !el.hasAttribute("hidden") && cs.display !== "none" && cs.visibility !== "hidden";
  }

  function measure(sel) {
    const el = q(sel);
    if (!el) return { selector: sel, found: false };

    const rect = el.getBoundingClientRect();
    const cs = window.getComputedStyle(el);

    return {
      selector: sel,
      found: true,
      visible: visible(el),
      height: Math.round(rect.height),
      width: Math.round(rect.width),
      display: cs.display,
      position: cs.position,
      flex: cs.flex,
      minHeight: cs.minHeight,
      maxHeight: cs.maxHeight,
      overflowY: cs.overflowY,
      boxSizing: cs.boxSizing,
      marginTop: cs.marginTop,
      marginBottom: cs.marginBottom,
      paddingTop: cs.paddingTop,
      paddingBottom: cs.paddingBottom,
      borderTopWidth: cs.borderTopWidth,
      borderBottomWidth: cs.borderBottomWidth,
    };
  }

  function activeTelemetryPanel() {
    const candidates = [
      "#obs-panel-recent",
      "#obs-panel-activity",
      "#obs-panel-events",
    ];
    for (const sel of candidates) {
      const el = q(sel);
      if (visible(el)) return sel;
    }
    return null;
  }

  async function sendEvidence(payload) {
    try {
      await fetch("/api/phase16-beacon", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
        keepalive: true,
      });
    } catch (_) {}
  }

  function capture() {
    const payload = {
      kind: "phase490.height.evidence",
      ts: Date.now(),
      activeTelemetryPanel: activeTelemetryPanel(),
      measurements: [
        measure("#operator-workspace-card"),
        measure("#observational-workspace-card"),
        measure("#operator-panels"),
        measure("#observational-panels"),
        measure("#op-panel-chat"),
        measure("#op-panel-delegation"),
        measure("#chat-card"),
        measure("#delegation-card"),
        measure("#matilda-chat-transcript"),
        measure("#delegation-status-panel"),
        measure("#obs-panel-recent"),
        measure("#obs-panel-activity"),
        measure("#obs-panel-events"),
        measure("#recent-tasks-card"),
        measure("#task-activity-card"),
        measure("#task-events-card"),
        measure("#recentTasks"),
        measure("#recentLogs"),
        measure("#mb-task-events-panel-anchor"),
        measure("#task-activity-graph"),
      ],
    };

    window.__PHASE490_HEIGHT_EVIDENCE__ = payload;
    console.log("[phase490] height evidence", payload);
    sendEvidence(payload);
  }

  function boot() {
    capture();
    window.addEventListener("load", capture);
    window.addEventListener("resize", () => requestAnimationFrame(capture));
    document.addEventListener("click", () => requestAnimationFrame(capture));
    setTimeout(capture, 500);
    setTimeout(capture, 1500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
