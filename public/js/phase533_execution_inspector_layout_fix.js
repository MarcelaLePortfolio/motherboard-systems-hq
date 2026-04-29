(function () {
  if (window.__PHASE533_EXECUTION_INSPECTOR_LAYOUT_FIX__) return;
  window.__PHASE533_EXECUTION_INSPECTOR_LAYOUT_FIX__ = true;

  function applyLayout() {
    const inspector = document.getElementById("execution-inspector");
    if (!inspector) return;

    const parentCard = inspector.closest(".obs-surface");
    if (!parentCard) return;

    parentCard.style.display = "flex";
    parentCard.style.flexDirection = "column";
    parentCard.style.height = "100%";
    parentCard.style.minHeight = "0";

    inspector.style.flex = "1 1 auto";
    inspector.style.height = "100%";
    inspector.style.minHeight = "0";
    inspector.style.overflow = "auto";
    inspector.style.display = "flex";
    inspector.style.flexDirection = "column";
  }

  function boot() {
    applyLayout();

    const observer = new MutationObserver(() => {
      requestAnimationFrame(applyLayout);
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
