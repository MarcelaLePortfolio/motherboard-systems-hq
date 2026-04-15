(() => {
  if (window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__) return;
  window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__ = true;

  function px(n) {
    return `${Math.max(0, Math.round(n))}px`;
  }

  function q(sel) {
    return document.querySelector(sel);
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
    el.style.flex = `0 0 ${px(h)}`;
    el.style.boxSizing = "border-box";
  }

  function setColumn(el) {
    if (!el) return;
    el.style.display = "flex";
    el.style.flexDirection = "column";
    el.style.minHeight = "0";
    el.style.overflow = "hidden";
    el.style.alignSelf = "stretch";
  }

  function setFill(el) {
    if (!el) return;
    el.style.flex = "1 1 auto";
    el.style.minHeight = "0";
    el.style.height = "100%";
    el.style.maxHeight = "100%";
    el.style.boxSizing = "border-box";
  }

  function syncOperatorHeights() {
    const operatorPanels = first(
      q("#operator-panels"),
      q("#operator-workspace-card #operator-panels")
    );

    const chatPanel = first(
      q("#op-panel-chat"),
      q("#operator-panels > #op-panel-chat")
    );

    const delegationPanel = first(
      q("#op-panel-delegation"),
      q("#operator-panels > #op-panel-delegation")
    );

    const chatCard = first(
      q("#chat-card"),
      q("#op-panel-chat #chat-card"),
      q("#op-panel-chat > section")
    );

    const delegationCard = first(
      q("#delegation-card"),
      q("#op-panel-delegation #delegation-card"),
      q("#op-panel-delegation > section"),
      q("#op-panel-delegation section")
    );

    const delegationStatus = q("#delegation-status-panel");
    const delegationInput = first(
      q("#delegation-input"),
      q("#op-panel-delegation textarea")
    );
    const delegationActions = first(
      q("#op-panel-delegation .flex.flex-col.md\\:flex-row.md\\:items-center.md\\:justify-between.gap-3"),
      q("#op-panel-delegation .gap-3")
    );

    if (!operatorPanels || !chatPanel || !delegationPanel || !chatCard || !delegationCard) return;
    if (!visible(chatPanel) || !visible(delegationPanel)) return;

    const target = outerHeight(chatPanel);
    if (!target || target < 100) return;

    operatorPanels.style.alignItems = "stretch";

    setExactHeight(chatPanel, target);
    setExactHeight(delegationPanel, target);

    setColumn(chatPanel);
    setColumn(delegationPanel);

    setFill(chatCard);
    setColumn(chatCard);

    setFill(delegationCard);
    setColumn(delegationCard);

    if (delegationInput) {
      delegationInput.style.flex = "0 0 auto";
      delegationInput.style.height = "auto";
      delegationInput.style.minHeight = "";
      delegationInput.style.maxHeight = "";
    }

    if (delegationActions) {
      delegationActions.style.flex = "0 0 auto";
    }

    if (delegationStatus) {
      delegationStatus.style.flex = "1 1 auto";
      delegationStatus.style.minHeight = "0";
      delegationStatus.style.height = "auto";
      delegationStatus.style.maxHeight = "none";
      delegationStatus.style.overflowY = "auto";
    }
  }

  function boot() {
    const rerun = () => window.requestAnimationFrame(syncOperatorHeights);

    syncOperatorHeights();

    window.addEventListener("resize", rerun);
    window.addEventListener("load", rerun);
    document.addEventListener("click", rerun);
    document.addEventListener("input", rerun);

    const opTabs = q("#operator-tabs");
    if (opTabs) opTabs.addEventListener("click", rerun);

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
