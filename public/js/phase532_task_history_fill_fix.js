(function () {
  if (window.__PHASE532_TASK_HISTORY_FILL_FIX__) return;
  window.__PHASE532_TASK_HISTORY_FILL_FIX__ = true;

  function applyLayout() {
    const card = document.getElementById("task-activity-card");
    const canvas = document.getElementById("task-activity-graph");
    if (!card || !canvas) return;

    const shell = canvas.parentElement;
    const panel = document.getElementById("obs-panel-activity");

    if (panel) {
      panel.style.height = "100%";
      panel.style.minHeight = "0";
      panel.style.display = "flex";
      panel.style.flexDirection = "column";
    }

    card.style.height = "100%";
    card.style.minHeight = "0";
    card.style.display = "flex";
    card.style.flexDirection = "column";
    card.style.padding = "0";
    card.style.overflow = "hidden";

    if (shell) {
      shell.style.flex = "1 1 auto";
      shell.style.height = "100%";
      shell.style.minHeight = "0";
      shell.style.width = "100%";
      shell.style.display = "flex";
      shell.style.padding = "0.75rem";
      shell.style.boxSizing = "border-box";
    }

    canvas.style.flex = "1 1 auto";
    canvas.style.width = "100%";
    canvas.style.height = "100%";
    canvas.style.minHeight = "0";
    canvas.style.display = "block";

    if (window.__PHASE530_ACTIVITY_CHART__) {
      window.__PHASE530_ACTIVITY_CHART__.resize();
      window.__PHASE530_ACTIVITY_CHART__.update();
    }
  }

  function boot() {
    applyLayout();
    window.requestAnimationFrame(applyLayout);
    setTimeout(applyLayout, 500);
    window.addEventListener("resize", applyLayout);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
