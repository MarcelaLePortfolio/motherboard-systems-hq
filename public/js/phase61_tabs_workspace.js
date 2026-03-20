document.addEventListener("DOMContentLoaded", () => {
  const workspaceRoots = Array.from(document.querySelectorAll("[data-workspace-root]"));
  workspaceRoots.forEach((root) => {
    const tabs = Array.from(root.querySelectorAll("[data-workspace-tab]"));
    const panels = Array.from(root.querySelectorAll("[data-workspace-panel]"));
    if (!tabs.length || !panels.length) return;
    const activate = (targetId) => {
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
    };
    tabs.forEach((tab) => tab.addEventListener("click", () => activate(tab.dataset.target)));
    const defaultTab = tabs.find((tab) => tab.classList.contains("active")) || tabs[0];
    if (defaultTab && defaultTab.dataset.target) activate(defaultTab.dataset.target);
  });
});
