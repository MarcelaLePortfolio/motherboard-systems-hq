(function () {
  if (window.__PHASE530_DOM_PROBE__) return;
  window.__PHASE530_DOM_PROBE__ = true;

  console.log("[phase530][probe] DOM probe active");

  function logAgentPoolState() {
    const pool = document.getElementById("agent-status-container");
    if (!pool) {
      console.log("[phase530][probe] agent-status-container not found");
      return;
    }

    console.log("[phase530][probe] agent-status-container HTML snapshot:");
    console.log(pool.innerHTML.slice(0, 500));
  }

  // Log after load
  window.addEventListener("load", () => {
    setTimeout(logAgentPoolState, 1000);
  });

  // Watch for overwrites
  const observer = new MutationObserver((mutations) => {
    console.log("[phase530][probe] DOM mutation detected", mutations.length);
    logAgentPoolState();
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true,
  });
})();
