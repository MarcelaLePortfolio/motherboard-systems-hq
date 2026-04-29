(function () {
  if (window.__PHASE532_TASK_HISTORY_FILL_FIX__) return;
  window.__PHASE532_TASK_HISTORY_FILL_FIX__ = true;

  function resizeChart() {
    if (!window.__PHASE530_ACTIVITY_CHART__) return;

    window.requestAnimationFrame(() => {
      window.__PHASE530_ACTIVITY_CHART__.resize();
      window.__PHASE530_ACTIVITY_CHART__.update();
    });
  }

  function bindTabResize() {
    const tab = document.getElementById("obs-tab-activity");
    if (!tab) return;

    tab.addEventListener("click", () => {
      setTimeout(resizeChart, 80);
      setTimeout(resizeChart, 250);
      setTimeout(resizeChart, 600);
    });
  }

  function boot() {
    bindTabResize();
    setTimeout(resizeChart, 500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
