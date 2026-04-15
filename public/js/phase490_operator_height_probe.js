(() => {
  if (window.__PHASE490_OPERATOR_HEIGHT_PROBE__) return;
  window.__PHASE490_OPERATOR_HEIGHT_PROBE__ = true;

  function q(sel) {
    return document.querySelector(sel);
  }

  function visible(el) {
    if (!el) return false;
    const cs = window.getComputedStyle(el);
    return !el.hasAttribute("hidden") && cs.display !== "none" && cs.visibility !== "hidden";
  }

  function outerHeight(el) {
    if (!el) return 0;
    const rect = el.getBoundingClientRect();
    const cs = window.getComputedStyle(el);
    const mt = parseFloat(cs.marginTop || "0") || 0;
    const mb = parseFloat(cs.marginBottom || "0") || 0;
    return Math.round(rect.height + mt + mb);
  }

  function measure(sel) {
    const el = q(sel);
    if (!el) return `${sel}: MISSING`;
    const cs = window.getComputedStyle(el);
    return [
      `${sel}`,
      `  visible=${visible(el)}`,
      `  h=${Math.round(el.getBoundingClientRect().height)}`,
      `  outer=${outerHeight(el)}`,
      `  display=${cs.display}`,
      `  flex=${cs.flex}`,
      `  minH=${cs.minHeight}`,
      `  maxH=${cs.maxHeight}`,
      `  mb=${cs.marginBottom}`
    ].join("\n");
  }

  function render() {
    let panel = document.getElementById("phase490-operator-height-probe");
    if (!panel) {
      panel = document.createElement("pre");
      panel.id = "phase490-operator-height-probe";
      panel.style.position = "fixed";
      panel.style.right = "12px";
      panel.style.bottom = "12px";
      panel.style.zIndex = "99999";
      panel.style.margin = "0";
      panel.style.padding = "10px 12px";
      panel.style.maxWidth = "360px";
      panel.style.maxHeight = "260px";
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
      "PHASE490 OPERATOR HEIGHT PROBE",
      "",
      measure("#operator-panels"),
      "",
      measure("#op-panel-chat"),
      "",
      measure("#chat-card"),
      "",
      measure("#op-panel-delegation"),
      "",
      measure("#delegation-card"),
      "",
      measure("#delegation-status-panel"),
      "",
      measure("#delegation-input")
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
