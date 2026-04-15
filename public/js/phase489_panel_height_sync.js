(() => {
  if (window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__) return;
  window.__PHASE489_PANEL_HEIGHT_SYNC_ACTIVE__ = true;

  const q = (s) => document.querySelector(s);

  function px(n) {
    return `${Math.max(0, Math.round(n))}px`;
  }

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

  function visible(el) {
    if (!el) return false;
    const cs = getComputedStyle(el);
    return !el.hasAttribute("hidden") && cs.display !== "none";
  }

  function lockHeight(el, h) {
    if (!el) return;
    el.style.height = px(h);
    el.style.minHeight = px(h);
    el.style.maxHeight = px(h);
    el.style.flex = `0 0 ${px(h)}`;
    el.style.boxSizing = "border-box";
  }

  function column(el) {
    if (!el) return;
    el.style.display = "flex";
    el.style.flexDirection = "column";
    el.style.minHeight = "0";
    el.style.overflow = "hidden";
    el.style.alignSelf = "stretch";
  }

  function fill(el) {
    if (!el) return;
    el.style.flex = "1 1 auto";
    el.style.minHeight = "0";
    el.style.height = "100%";
    el.style.maxHeight = "100%";
  }

  function findActivePanel(root) {
    return [...root.children].find((el) => visible(el));
  }

  function sync() {
    const operatorPanels = q("#operator-panels");
    if (!operatorPanels) return;

    const activePanel = findActivePanel(operatorPanels);
    if (!activePanel) return;

    const chatPanel = q("#op-panel-chat");
    const delegationPanel = q("#op-panel-delegation");

    const activeHeight = outerHeight(activePanel);
    if (!activeHeight || activeHeight < 100) return;

    // 🔥 THIS IS THE FIX:
    // We DO NOT measure Matilda specifically anymore.
    // We measure whichever panel is currently visible.
    // Then force BOTH panels to that height.

    [chatPanel, delegationPanel].forEach((panel) => {
      if (!panel) return;

      lockHeight(panel, activeHeight);
      column(panel);

      const card = panel.querySelector("section") || panel;
      fill(card);
      column(card);
    });

    // delegation internals
    const status = q("#delegation-status-panel");
    if (status) {
      status.style.flex = "1 1 auto";
      status.style.minHeight = "0";
      status.style.overflowY = "auto";
    }

    const input = q("#delegation-input") || q("#op-panel-delegation textarea");
    if (input) {
      input.style.flex = "0 0 auto";
    }
  }

  function boot() {
    const rerun = () => requestAnimationFrame(sync);

    sync();

    window.addEventListener("resize", rerun);
    window.addEventListener("load", rerun);
    document.addEventListener("click", rerun);
    document.addEventListener("input", rerun);

    const tabs = q("#operator-tabs");
    if (tabs) tabs.addEventListener("click", rerun);

    const mo = new MutationObserver(rerun);
    mo.observe(document.body, {
      subtree: true,
      childList: true,
      attributes: true
    });

    setInterval(sync, 1200);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
