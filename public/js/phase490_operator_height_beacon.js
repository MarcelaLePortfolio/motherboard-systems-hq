(() => {
  if (window.__PHASE490_OPERATOR_HEIGHT_BEACON__) return;
  window.__PHASE490_OPERATOR_HEIGHT_BEACON__ = true;

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
    if (!el) return { selector: sel, found: false };

    const rect = el.getBoundingClientRect();
    const cs = window.getComputedStyle(el);

    return {
      selector: sel,
      found: true,
      visible: visible(el),
      height: Math.round(rect.height),
      outerHeight: outerHeight(el),
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
      borderBottomWidth: cs.borderBottomWidth
    };
  }

  function renderDebug(payload) {
    let pre = document.getElementById("phase490-operator-height-readout");
    if (!pre) {
      pre = document.createElement("pre");
      pre.id = "phase490-operator-height-readout";
      pre.style.position = "fixed";
      pre.style.left = "12px";
      pre.style.bottom = "12px";
      pre.style.zIndex = "99999";
      pre.style.margin = "0";
      pre.style.padding = "10px 12px";
      pre.style.maxWidth = "360px";
      pre.style.maxHeight = "220px";
      pre.style.overflow = "auto";
      pre.style.background = "rgba(2,6,23,0.94)";
      pre.style.color = "#e2e8f0";
      pre.style.border = "1px solid rgba(71,85,105,0.95)";
      pre.style.borderRadius = "12px";
      pre.style.fontSize = "11px";
      pre.style.lineHeight = "1.35";
      pre.style.fontFamily = "ui-monospace, SFMono-Regular, Menlo, monospace";
      pre.style.whiteSpace = "pre-wrap";
      pre.style.pointerEvents = "none";
      pre.style.boxShadow = "0 10px 30px rgba(0,0,0,0.35)";
      document.body.appendChild(pre);
    }

    const rows = payload.measurements.map((m) => {
      if (!m.found) return `${m.selector}: MISSING`;
      return `${m.selector}\n  h=${m.height} outer=${m.outerHeight} display=${m.display} flex=${m.flex} mb=${m.marginBottom}`;
    });

    pre.textContent = ["PHASE490 OPERATOR HEIGHT", ...rows].join("\n");
  }

  function capture() {
    const payload = {
      kind: "phase490.operator.height.beacon",
      ts: Date.now(),
      measurements: [
        measure("#operator-panels"),
        measure("#op-panel-chat"),
        measure("#op-panel-delegation"),
        measure("#chat-card"),
        measure("#delegation-card"),
        measure("#matilda-chat-transcript"),
        measure("#operator-guidance-panel"),
        measure("#delegation-status-panel"),
        measure("#delegation-input")
      ]
    };

    renderDebug(payload);
    window.__PHASE490_OPERATOR_HEIGHT_LAST__ = payload;
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
