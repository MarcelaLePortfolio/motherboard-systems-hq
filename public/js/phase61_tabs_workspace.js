document.addEventListener("DOMContentLoaded", () => {
  const tabs = Array.from(document.querySelectorAll(".obs-tab"));
  const panels = Array.from(document.querySelectorAll(".obs-panel"));

  if (!tabs.length || !panels.length) return;

  function activate(targetId) {
    tabs.forEach((tab) => {
      const isActive = tab.dataset.target === targetId;
      tab.classList.toggle("active", isActive);
      tab.setAttribute("aria-selected", String(isActive));
    });

    panels.forEach((panel) => {
      const isActive = panel.id === targetId;
      panel.classList.toggle("active", isActive);
      panel.hidden = !isActive;
    });
  }

  tabs.forEach((tab) => {
    tab.addEventListener("click", () => {
      const targetId = tab.dataset.target;
      if (!targetId) return;
      activate(targetId);
    });
  });

  const defaultTab = tabs.find((tab) => tab.classList.contains("active")) || tabs[0];
  if (defaultTab && defaultTab.dataset.target) {
    activate(defaultTab.dataset.target);
  }
});
