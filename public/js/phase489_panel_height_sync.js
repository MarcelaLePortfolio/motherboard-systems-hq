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

  function findMatildaReference() {
    return first(
      byId("chat-card"),
      document.querySelector("#op-panel-chat #chat-card"),
      document.querySelector("#op-panel-chat section"),
      byId("op-panel-chat")
    );
  }

  function findDelegationCard() {
    return first(
      byId("delegation-card"),
      document.querySelector("#op-panel-delegation #delegation-card"),
      document.querySelector("#op-panel-delegation section"),
      byId("op-panel-delegation")
    );
  }

  function syncOperatorHeights() {
    const reference = findMatildaReference();
    const delegation = findDelegationCard();

    if (!reference || !delegation || !visible(reference) || !visible(delegation)) return;

    const target = outerHeight(reference);
    if (!target || target < 100) return;

    delegation.style.height = px(target);
    delegation.style.minHeight = px(target);
    delegation.style.maxHeight = px(target);
    delegation.style.boxSizing = "border-box";
    delegation.style.display = "flex";
    delegation.style.flexDirection = "column";
    delegation.style.overflow = "hidden";

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
    syncOperatorHeights();

    const rerun = () => window.requestAnimationFrame(syncOperatorHeights);

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
