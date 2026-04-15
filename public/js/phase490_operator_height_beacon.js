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

  async function send(payload) {
    try {
      await fetch("/api/phase16-beacon", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
        keepalive: true
      });
    } catch (_) {}
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

    console.log("[phase490-operator-height-beacon]", payload);
    send(payload);
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
