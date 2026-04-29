(function () {
  if (window.__PHASE531_RECENT_TASKS_LAYOUT_FIX__) return;
  window.__PHASE531_RECENT_TASKS_LAYOUT_FIX__ = true;

  function applyLayout() {
    const card = document.getElementById("recent-tasks-card");
    const tasks = document.getElementById("recentTasks");
    const logs = document.getElementById("recentLogs");

    if (!card || !tasks || !logs) return;

    const taskSection = tasks.parentElement;
    const logSection = logs.parentElement;

    card.style.display = "grid";
    card.style.gridTemplateRows = "minmax(0, 1fr) minmax(0, 1fr)";
    card.style.gridTemplateColumns = "minmax(0, 1fr)";
    card.style.height = "100%";
    card.style.minHeight = "0";
    card.style.gap = "1rem";
    card.style.alignItems = "stretch";

    [taskSection, logSection].forEach((section) => {
      if (!section) return;
      section.style.display = "grid";
      section.style.gridTemplateRows = "auto minmax(0, 1fr)";
      section.style.minHeight = "0";
      section.style.height = "100%";
    });

    [tasks, logs].forEach((el) => {
      el.style.height = "100%";
      el.style.minHeight = "0";
      el.style.overflow = "auto";
      el.style.display = "block";
      el.style.boxSizing = "border-box";
    });
  }

  function boot() {
    applyLayout();

    const observer = new MutationObserver(() => {
      window.requestAnimationFrame(applyLayout);
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ["style", "class", "hidden"],
    });

    setInterval(applyLayout, 1000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
