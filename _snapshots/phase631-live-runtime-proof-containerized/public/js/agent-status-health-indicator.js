(() => {
  "use strict";

  function getTarget() {
    const container = document.getElementById("agent-status-container");
    if (!container) return null;

    // Prefer header if present, otherwise fall back to container
    const header = container.querySelector("h2");
    return header || container;
  }

  function ensureIndicator(target) {
    let indicator = document.getElementById("agent-pool-health-indicator");

    if (!indicator) {
      indicator = document.createElement("span");
      indicator.id = "agent-pool-health-indicator";
      indicator.style.marginLeft = "8px";
      indicator.style.fontSize = "12px";
      indicator.style.display = "inline-block";
      target.appendChild(indicator);
    }

    return indicator;
  }

  function updateIndicator() {
    const target = getTarget();
    if (!target) {
      if (window.__UI_DEBUG) {
        console.warn("[agent-pool-health] container not found");
      }
      return;
    }

    const indicator = ensureIndicator(target);
    const healthy = window.__AGENT_POOL_HEALTH;

    indicator.textContent = healthy ? "●" : "○";
    indicator.style.color = healthy ? "#34d399" : "#f87171";

    if (window.__UI_DEBUG) {
      console.log("[agent-pool-health]", { healthy });
    }
  }

  // Retry until container exists (hydration-safe)
  const boot = () => {
    const target = getTarget();
    if (!target) {
      setTimeout(boot, 500);
      return;
    }

    setInterval(updateIndicator, 2000);
    updateIndicator();

    console.log("[agent-pool-health] indicator active");
  };

  boot();
})();
