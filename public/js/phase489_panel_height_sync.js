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
    return !el.hasAttribute("hidden") && cs.display !== "none";
  }

  function outerHeight(el) {
    if (!el) return 0;
    const rect = el.getBoundingClientRect();
    const cs = window.getComputedStyle(el);
    const mt = parseFloat(cs.marginTop || "0") || 0;
    const mb = parseFloat(cs.marginBottom || "0") || 0;
    return Math.round(rect.height + mt + mb);
  }

  function sync() {
    const chatPanel = q("#op-panel-chat");
    const delegationPanel = q("#op-panel-delegation");

    if (!chatPanel || !delegationPanel) return;
    if (!visible(chatPanel) || !visible(delegationPanel)) return;

    const target = outerHeight(chatPanel);
    if (!target || target < 100) return;

    // HARD LOCK: apply to BOTH panels (this is what was missing)
    [chatPanel, delegationPanel].forEach((panel) => {
      panel.style.height = px(target);
      panel.style.minHeight = px(target);
      panel.style.maxHeight = px(target);
      panel.style.boxSizing = "border-box";
      panel.style.display = "flex";
      panel.style.flexDirection = "column";
      panel.style.overflow = "hidden";
    });

    // normalize inner surfaces
    const delegationCard = q("#delegation-card") || q("#op-panel-delegation section");
    if (delegationCard) {
      delegationCard.style.flex = "1 1 auto";
      delegationCard.style.minHeight = "0";
      delegationCard.style.height = "100%";
      delegationCard.style.maxHeight = "100%";
      delegationCard.style.display = "flex";
      delegationCard.style.flexDirection = "column";
    }

    const status = q("#delegation-status-panel");
    if (status) {
      status.style.flex = "1 1 auto";
      status.style.minHeight = "0";
      status.style.overflowY = "auto";
    }
  }

  function boot() {
    const rerun = () => window.requestAnimationFrame(sync);

    sync();
    window.addEventListener("resize", rerun);
    window.addEventListener("load", rerun);
    document.addEventListener("click", rerun);
    document.addEventListener("input", rerun);

    const mo = new MutationObserver(rerun);
    mo.observe(document.body, { subtree: true, childList: true, attributes: true });

    window.setInterval(sync, 1200);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
