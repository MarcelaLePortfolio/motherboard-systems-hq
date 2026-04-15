(() => {
  if (window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__) return;
  window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__ = true;

  function px(n) {
    return `${Math.max(0, Math.round(n))}px`;
  }

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

  function first() {
    for (const el of arguments) {
      if (el) return el;
    }
    return null;
  }

  function findRenderedChatContainer() {
    return first(
      q("#chat-card"),
      q("#op-panel-chat #chat-card"),
      q("#op-panel-chat > section"),
      q("#op-panel-chat")
    );
  }

  function findDelegationPanel() {
    return first(
      q("#op-panel-delegation"),
      q("#operator-panels > #op-panel-delegation")
    );
  }

  function findDelegationCard() {
    return first(
      q("#delegation-card"),
      q("#op-panel-delegation #delegation-card"),
      q("#op-panel-delegation > section"),
      q("#op-panel-delegation section")
    );
  }

  function setExactHeight(el, h) {
    if (!el) return;
    el.style.height = px(h);
    el.style.minHeight = px(h);
    el.style.maxHeight = px(h);
    el.style.boxSizing = "border-box";
  }

  function setColumn(el) {
    if (!el) return;
    el.style.display = "flex";
    el.style.flexDirection = "column";
    el.style.minHeight = "0";
    el.style.overflow = "hidden";
  }

  function syncOperatorHeights() {
    const chatContainer = findRenderedChatContainer();
    const delegationPanel = findDelegationPanel();
    const delegationCard = findDelegationCard();

    if (!chatContainer || !delegationPanel || !delegationCard) return;
    if (!visible(chatContainer) || !visible(delegationPanel)) return;

    const target = outerHeight(chatContainer);
    if (!target || target < 100) return;

    setExactHeight(delegationPanel, target);
    setColumn(delegationPanel);

    delegationCard.style.flex = "1 1 auto";
    delegationCard.style.minHeight = "0";
    delegationCard.style.height = "100%";
    delegationCard.style.maxHeight = "100%";
    delegationCard.style.display = "flex";
    delegationCard.style.flexDirection = "column";
    delegationCard.style.boxSizing = "border-box";
    delegationCard.style.overflow = "hidden";

    const status = q("#delegation-status-panel");
    if (status) {
      status.style.flex = "1 1 auto";
      status.style.minHeight = "0";
      status.style.overflowY = "auto";
    }

    const input = first(
      q("#delegation-input"),
      q("#op-panel-delegation textarea")
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
