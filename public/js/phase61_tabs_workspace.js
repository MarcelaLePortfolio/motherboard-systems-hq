(() => {
  if (window.__PHASE61_TABS_WORKSPACE_ACTIVE__) return;
  window.__PHASE61_TABS_WORKSPACE_ACTIVE__ = true;

  function qsa(root, selector) {
    return Array.from((root || document).querySelectorAll(selector));
  }

  function setSelected(tab, selected) {
    tab.classList.toggle("active", selected);
    tab.setAttribute("aria-selected", selected ? "true" : "false");
    if (selected) {
      tab.removeAttribute("tabindex");
    } else {
      tab.setAttribute("tabindex", "-1");
    }
  }

  function setPanelVisible(panel, visible) {
    panel.classList.toggle("active", visible);
    if (visible) {
      panel.removeAttribute("hidden");
      panel.setAttribute("aria-hidden", "false");
      panel.style.display = "";
    } else {
      panel.setAttribute("hidden", "");
      panel.setAttribute("aria-hidden", "true");
      panel.style.display = "none";
    }
  }

  function activateTab(groupRoot, targetId) {
    const tabs = qsa(groupRoot, "[data-workspace-tab]");
    const panels = qsa(groupRoot, "[data-workspace-panel]");

    let matched = false;

    tabs.forEach((tab) => {
      const isSelected = tab.getAttribute("data-target") === targetId;
      setSelected(tab, isSelected);
      if (isSelected) matched = true;
    });

    panels.forEach((panel) => {
      setPanelVisible(panel, panel.id === targetId);
    });

    return matched;
  }

  function installTabGroup(tablistId, panelContainerId) {
    const tablist = document.getElementById(tablistId);
    const panelContainer = document.getElementById(panelContainerId);

    if (!tablist || !panelContainer) return false;

    const groupRoot = tablist.parentElement || document;
    const tabs = qsa(tablist, "[data-workspace-tab]");
    const panels = qsa(panelContainer, "[data-workspace-panel]");

    if (!tabs.length || !panels.length) return false;

    tabs.forEach((tab) => {
      tab.setAttribute("role", "tab");
      tab.type = "button";

      tab.addEventListener("click", (event) => {
        event.preventDefault();
        const targetId = tab.getAttribute("data-target");
        if (!targetId) return;
        activateTab(groupRoot, targetId);
      });

      tab.addEventListener("keydown", (event) => {
        const currentIndex = tabs.indexOf(tab);
        if (currentIndex < 0) return;

        let nextIndex = currentIndex;

        if (event.key === "ArrowRight" || event.key === "ArrowDown") {
          nextIndex = (currentIndex + 1) % tabs.length;
        } else if (event.key === "ArrowLeft" || event.key === "ArrowUp") {
          nextIndex = (currentIndex - 1 + tabs.length) % tabs.length;
        } else if (event.key === "Home") {
          nextIndex = 0;
        } else if (event.key === "End") {
          nextIndex = tabs.length - 1;
        } else {
          return;
        }

        event.preventDefault();
        const nextTab = tabs[nextIndex];
        const targetId = nextTab.getAttribute("data-target");
        if (!targetId) return;
        activateTab(groupRoot, targetId);
        nextTab.focus();
      });
    });

    panels.forEach((panel) => {
      panel.setAttribute("role", "tabpanel");
    });

    const preselected =
      tabs.find((tab) => tab.classList.contains("active")) ||
      tabs.find((tab) => tab.getAttribute("aria-selected") === "true") ||
      tabs[0];

    const targetId = preselected?.getAttribute("data-target");
    if (targetId) {
      activateTab(groupRoot, targetId);
    }

    return true;
  }

  function boot() {
    installTabGroup("operator-tabs", "operator-panels");
    installTabGroup("observational-tabs", "observational-panels");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
