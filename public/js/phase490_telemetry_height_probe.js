(() => {
  if (window.__PHASE490_TELEMETRY_HEIGHT_PROBE__) return;
  window.__PHASE490_TELEMETRY_HEIGHT_PROBE__ = true;

  const q = (s) => document.querySelector(s);

  function outerHeight(el) {
    if (!el) return 0;
    const r = el.getBoundingClientRect();
    const cs = getComputedStyle(el);
    return Math.round(
      r.height +
      (parseFloat(cs.marginTop) || 0) +
      (parseFloat(cs.marginBottom) || 0)
    );
  }

  function measure(sel) {
    const el = q(sel);
    if (!el) return `${sel}: MISSING`;
    return `${sel}: ${outerHeight(el)}`;
  }

  function render() {
    let panel = document.getElementById("phase490-telemetry-height-probe");
    if (!panel) {
      panel = document.createElement("pre");
      panel.id = "phase490-telemetry-height-probe";
      panel.style.position = "fixed";
      panel.style.left = "12px";
      panel.style.bottom = "12px";
      panel.style.zIndex = "99999";
      panel.style.margin = "0";
      panel.style.padding = "10px 12px";
      panel.style.maxWidth = "320px";
      panel.style.maxHeight = "180px";
      panel.style.overflow = "auto";
      panel.style.background = "rgba(2,6,23,0.94)";
      panel.style.color = "#e2e8f0";
      panel.style.border = "1px solid rgba(71,85,105,0.95)";
      panel.style.borderRadius = "12px";
      panel.style.fontSize = "11px";
      panel.style.lineHeight = "1.35";
      panel.style.fontFamily = "ui-monospace, SFMono-Regular, Menlo, monospace";
      panel.style.whiteSpace = "pre-wrap";
      document.body.appendChild(panel);
    }

    panel.textContent = [
      "PHASE490 TELEMETRY HEIGHTS",
      measure("#op-panel-chat"),
      measure("#op-panel-delegation"),
      measure("#obs-panel-recent"),
      measure("#recent-tasks-card"),
      measure("#obs-panel-activity"),
      measure("#task-activity-card"),
      measure("#obs-panel-events"),
      measure("#task-events-card")
    ].join("\n");
  }

  function boot() {
    render();
    window.addEventListener("load", render);
    window.addEventListener("resize", () => requestAnimationFrame(render));
    document.addEventListener("click", () => requestAnimationFrame(render));
    setTimeout(render, 500);
    setTimeout(render, 1500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
