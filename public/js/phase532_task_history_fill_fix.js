(function () {
  if (window.__PHASE532_TASK_HISTORY_FILL_FIX__) return;
  window.__PHASE532_TASK_HISTORY_FILL_FIX__ = true;

  function fitChartToVisiblePanel() {
    const panel = document.getElementById("obs-panel-activity");
    const card = document.getElementById("task-activity-card");
    const canvas = document.getElementById("task-activity-graph");
    const chart = window.__PHASE530_ACTIVITY_CHART__;

    if (!panel || !card || !canvas || !chart) return;
    if (panel.hidden || panel.offsetParent === null) return;

    const wrapper = canvas.parentElement;
    if (!wrapper) return;

    card.style.height = "100%";
    card.style.minHeight = "0";

    wrapper.style.height = "100%";
    wrapper.style.minHeight = "0";

    canvas.style.width = "100%";
    canvas.style.height = "100%";

    chart.options.maintainAspectRatio = false;
    chart.resize();
    chart.update();
  }

  function boot() {
    const tab = document.getElementById("obs-tab-activity");

    if (tab) {
      tab.addEventListener("click", () => {
        setTimeout(fitChartToVisiblePanel, 100);
        setTimeout(fitChartToVisiblePanel, 350);
        setTimeout(fitChartToVisiblePanel, 800);
      });
    }

    setTimeout(fitChartToVisiblePanel, 800);
    window.addEventListener("resize", fitChartToVisiblePanel);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
