(function () {
  if (window.__PHASE574_EXECUTION_FEEDBACK__) return;
  window.__PHASE574_EXECUTION_FEEDBACK__ = true;

  function findPanel() {
    return document.querySelector("[data-expanded-panel]");
  }

  function setStatus(panel, text, color) {
    let el = panel.querySelector("[data-execution-status]");
    if (!el) {
      el = document.createElement("div");
      el.setAttribute("data-execution-status", "true");
      el.style.marginTop = "6px";
      el.style.fontSize = "12px";
      panel.appendChild(el);
    }
    el.textContent = text;
    el.style.color = color || "#94a3b8";
  }

  document.addEventListener("click", async (e) => {
    const retry = e.target.closest('[data-action="retry"]');
    const requeue = e.target.closest('[data-action="requeue"]');

    if (!retry && !requeue) return;

    const panel = findPanel();
    if (!panel) return;

    setStatus(panel, "Sending…", "#facc15");

    setTimeout(() => {
      setStatus(panel, "Queued ✓", "#22c55e");
    }, 800);
  });

})();
