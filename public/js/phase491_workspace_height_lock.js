(() => {
  const q = (sel) => document.querySelector(sel);

  function outerHeight(el) {
    if (!el) return 0;
    return el.getBoundingClientRect().height;
  }

  function lockWorkspaceHeights() {
    const operator = q("#operator-workspace-card");
    const telemetry = q("#observational-workspace-card");

    if (!operator || !telemetry) return;

    const target = outerHeight(operator);
    if (!target || target < 100) return;

    [operator, telemetry].forEach((el) => {
      el.style.height = target + "px";
      el.style.minHeight = target + "px";
      el.style.maxHeight = target + "px";
      el.style.overflow = "hidden";
      el.style.display = "flex";
      el.style.flexDirection = "column";
    });
  }

  function boot() {
    const rerun = () => requestAnimationFrame(lockWorkspaceHeights);

    lockWorkspaceHeights();

    window.addEventListener("resize", rerun);
    window.addEventListener("load", rerun);
    document.addEventListener("click", rerun);

    const mo = new MutationObserver(rerun);
    mo.observe(document.body, {
      subtree: true,
      childList: true,
      attributes: true
    });

    setInterval(lockWorkspaceHeights, 1200);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
