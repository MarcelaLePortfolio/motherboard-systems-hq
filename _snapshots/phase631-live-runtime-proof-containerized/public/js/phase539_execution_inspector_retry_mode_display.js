(function () {
  if (window.__PHASE539_RETRY_MODE_DISPLAY__) return;
  window.__PHASE539_RETRY_MODE_DISPLAY__ = true;

  function enhance() {
    const panel = document.querySelector("[data-expanded-panel]");
    if (!panel) return;

    const selected = panel.querySelector("div");
    if (!selected) return;

    const existing = panel.querySelector("[data-retry-mode-display]");
    if (existing) return;

    const taskLine = panel.innerText.split("\n").find(l => l.includes("task="));
    if (!taskLine) return;

    const taskId = taskLine.split("task=")[1]?.trim();
    if (!taskId) return;

    // Try to infer retry mode from DOM (best-effort, UI-only signal)
    const text = panel.innerText;
    let mode = "unknown";

    if (text.includes("fresh-context")) mode = "fresh-context";
    else if (text.includes("standard-retry")) mode = "standard-retry";

    const el = document.createElement("div");
    el.setAttribute("data-retry-mode-display", "true");
    el.style.marginTop = "0.35rem";
    el.style.fontSize = "0.7rem";
    el.style.color = "#94a3b8";
    el.style.fontFamily = "ui-monospace,SFMono-Regular,Menlo,monospace";

    el.textContent = "retry_mode: " + mode;

    panel.appendChild(el);
  }

  function boot() {
    setInterval(enhance, 500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
