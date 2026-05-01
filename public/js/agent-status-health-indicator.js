(() => {
  "use strict";

  function updateIndicator() {
    const container = document.getElementById("agent-status-container");
    if (!container) return;

    const header = container.querySelector("h2");
    if (!header) return;

    let indicator = document.getElementById("agent-pool-health-indicator");

    if (!indicator) {
      indicator = document.createElement("span");
      indicator.id = "agent-pool-health-indicator";
      indicator.style.marginLeft = "8px";
      indicator.style.fontSize = "12px";
      header.appendChild(indicator);
    }

    const healthy = window.__AGENT_POOL_HEALTH;

    indicator.textContent = healthy ? "●" : "○";
    indicator.style.color = healthy ? "#34d399" : "#f87171";
  }

  setInterval(updateIndicator, 2000);
})();
