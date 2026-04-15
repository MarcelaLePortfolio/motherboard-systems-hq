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
    for (const el of arguments) {
      if (el) return el;
    }
    return null;
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

  function setExactHeight(el, h) {
    if (!el) return;
    el.style.height = px(h);
    el.style.minHeight = px(h);
    el.style.maxHeight = px(h);
    el.style.boxSizing = "border-box";
  }

  function setFillColumn(el) {
    if (!el) return;
    el.style.display = "flex";
    el.style.flexDirection = "column";
    el.style.minHeight = "0";
  }

  function syncOperatorHeights() {
    const chatPanel = first(
      byId("op-panel-chat"),
      document.querySelector("#operator-panels > #op-panel-chat")
    );

    const delegationPanel = first(
      byId("op-panel-delegation"),
      document.querySelector("#operator-panels > #op-panel-delegation")
    );

    const delegationCard = first(
      byId("delegation-card"),
      document.querySelector("#op-panel-delegation #delegation-card"),
      document.querySelector("#op-panel-delegation section")
    );

    if (!chatPanel || !delegationPanel || !delegationCard) return;
    if (!visible(chatPanel) || !visible(delegationPanel)) return;

    const target = outerHeight(chatPanel);
    if (!target || target < 100) return;

    setExactHeight(delegationPanel, target);
    setFillColumn(delegationPanel);
    delegationPanel.style.overflow = "hidden";

    delegationCard.style.flex = "1 1 auto";
    delegationCard.style.minHeight = "0";
    delegationCard.style.height = "100%";
    delegationCard.style.maxHeight = "100%";
    delegationCard.style.display = "flex";
    delegationCard.style.flexDirection = "column";
    delegationCard.style.overflow = "hidden";
    delegationCard.style.boxSizing = "border-box";

    const status = byId("delegation-status-panel");
    if (status) {
      status.style.flex = "1 1 auto";
      status.style.minHeight = "0";
      status.style.overflowY = "auto";
    }

    const input = first(
      byId("delegation-input"),
      document.querySelector("#op-panel-delegation textarea")
    );
    if (input) {
      input.style.flex = "0 0 auto";
    }
  }

  function boot() {
    const rerun = () => window.requestAnimationFrame(syncOperatorHeights);

    syncOperatorHeights();
    window.addEventListener("resize", rerun);
    window.addEventListener("load", rerun);
    document.addEventListener("click", rerun);
    document.addEventListener("input", rerun);

    const opTabs = byId("operator-tabs");
    if (opTabs) {
      opTabs.addEventListener("click", rerun);
    }

    const mo = new MutationObserver(rerun);
    mo.observe(document.body, {
      subtree: true,
      childList: true,
      attributes: true,
      attributeFilter: ["class", "style", "hidden", "aria-hidden"]
    });

    window.setInterval(syncOperatorHeights, 1200);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
