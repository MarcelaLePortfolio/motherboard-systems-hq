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
    card.style.gap = "0.85rem";
    card.style.alignItems = "stretch";

    [taskSection, logSection].forEach((section) => {
      if (!section) return;
      section.style.display = "grid";
      section.style.gridTemplateRows = "auto minmax(0, 1fr)";
      section.style.gap = "0.45rem";
      section.style.minHeight = "0";
      section.style.height = "100%";
      section.style.margin = "0";

      const label = section.querySelector("h3");
      if (label) {
        label.style.margin = "0";
        label.style.fontSize = "0.75rem";
        label.style.lineHeight = "1rem";
        label.style.fontWeight = "700";
        label.style.letterSpacing = "0.16em";
        label.style.textTransform = "uppercase";
        label.style.color = "rgb(156, 163, 175)";
      }
    });

    [tasks, logs].forEach((el) => {
      el.className = "bg-gray-900 border border-gray-700 rounded-xl p-3 text-sm text-gray-300";
      el.style.height = "100%";
      el.style.minHeight = "0";
      el.style.overflow = "auto";
      el.style.display = "block";
      el.style.boxSizing = "border-box";
      el.style.background = "#111827";
      el.style.border = "1px solid rgb(55, 65, 81)";
      el.style.borderRadius = "0.75rem";
      el.style.padding = "0.75rem";
      el.style.color = "rgb(209, 213, 219)";
      el.style.fontFamily = "ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif";
      el.style.fontSize = "0.82rem";
      el.style.lineHeight = "1.45";
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
