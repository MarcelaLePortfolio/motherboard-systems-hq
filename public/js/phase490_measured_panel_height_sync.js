(() => {
  if (window.__PHASE490_MEASURED_PANEL_HEIGHT_SYNC__) return;
  window.__PHASE490_MEASURED_PANEL_HEIGHT_SYNC__ = true;

  function q(selector) {
    return document.querySelector(selector);
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

  function findReferenceCard() {
    const candidates = [
      q("#delegation-card"),
      q("#chat-card"),
      q("#op-panel-delegation #delegation-card"),
      q("#op-panel-chat #chat-card")
    ].filter(Boolean);

    return candidates.find(visible) || null;
  }

  function sync() {
    const ref = findReferenceCard();
    if (!ref) return;

    const h = outerHeight(ref);
    if (!h || h < 100) return;

    document.documentElement.style.setProperty("--phase490-chat-card-height", `${h}px`);
    document.documentElement.style.setProperty("--phase490-telemetry-card-height", `calc(${h}px - 4px)`);
  }

  function boot() {
    sync();

    const rerun = () => window.requestAnimationFrame(sync);
    window.addEventListener("resize", rerun);
    window.addEventListener("load", rerun);
    document.addEventListener("click", rerun);
    document.addEventListener("input", rerun);

    const mo = new MutationObserver(rerun);
    mo.observe(document.body, {
      subtree: true,
      childList: true,
      attributes: true,
      attributeFilter: ["class", "style", "hidden", "aria-hidden"]
    });

    window.setInterval(sync, 1200);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
