(function () {
  if (window.__PHASE531_RECENT_TASKS_LAYOUT_FIX__) return;
  window.__PHASE531_RECENT_TASKS_LAYOUT_FIX__ = true;

  console.log("[phase531] recent tasks layout fix active");

  function applyLayout() {
    const card = document.getElementById("recent-tasks-card");
    const tasks = document.getElementById("recentTasks");
    const logs = document.getElementById("recentLogs");

    if (!card || !tasks || !logs) return;

    // Split container into two equal rows
    card.style.display = "grid";
    card.style.gridTemplateRows = "1fr 1fr";
    card.style.height = "100%";
    card.style.minHeight = "0";
    card.style.gap = "0.75rem";

    // Ensure children fill their halves
    [tasks, logs].forEach((el) => {
      el.style.height = "100%";
      el.style.minHeight = "0";
      el.style.overflow = "auto";
      el.style.display = "flex";
      el.style.flexDirection = "column";
    });

    console.log("[phase531] layout applied");
  }

  function boot() {
    applyLayout();

    // Re-apply in case something overwrites DOM
    const observer = new MutationObserver(() => {
      applyLayout();
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true,
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
