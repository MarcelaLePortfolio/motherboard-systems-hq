(function () {
  if (window.__PHASE538_RETRY_STRATEGIES__) return;
  window.__PHASE538_RETRY_STRATEGIES__ = true;

  function bind() {
    const panel = document.querySelector("[data-expanded-panel]");
    if (!panel) return;

    const btn = panel.querySelector('[data-action="retry"]');
    if (!btn) return;

    btn.onclick = async (e) => {
      e.stopPropagation();

      const taskLine = panel.innerText.split("\n").find(l => l.includes("task="));
      if (!taskLine) return;

      const taskId = taskLine.split("task=")[1]?.trim();
      if (!taskId) return;

      // SIMPLE STRATEGY LAYER (first real behavioral upgrade)
      const strategy = e.shiftKey ? "fresh-context" : "standard-retry";

      const body = {
        title: "Retry task",
        source: "execution-inspector",
        kind: "retry",
        meta: {
          retry_of_task_id: taskId,
          retry_mode: strategy
        }
      };

      try {
        const res = await fetch("/api/delegate-task", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(body)
        });

        const data = await res.json();
        console.log("Retry result:", data);

        btn.textContent = strategy === "fresh-context" ? "Retry (Fresh) ✓" : "Retry ✓";
        btn.style.color = strategy === "fresh-context" ? "#60a5fa" : "#22c55e";

        setTimeout(() => {
          btn.textContent = "Retry";
          btn.style.color = "#60a5fa";
        }, 1500);

      } catch (err) {
        console.error("Retry failed:", err);
      }
    };
  }

  function boot() {
    setInterval(bind, 500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
