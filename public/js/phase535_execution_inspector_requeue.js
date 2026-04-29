(function () {
  if (window.__PHASE535_EXECUTION_INSPECTOR_REQUEUE__) return;
  window.__PHASE535_EXECUTION_INSPECTOR_REQUEUE__ = true;

  function bind() {
    const panel = document.querySelector("[data-expanded-panel]");
    if (!panel) return;

    const btn = panel.querySelector('[data-action="requeue"]');
    if (!btn) return;

    btn.onclick = async (e) => {
      e.stopPropagation();

      const taskLine = panel.innerText.split("\n").find(l => l.includes("task="));
      if (!taskLine) return;

      const taskId = taskLine.split("task=")[1]?.trim();
      if (!taskId) return;

      const body = {
        title: "Requeued task",
        source: "execution-inspector",
        kind: "retry",
        meta: {
          retry_of_task_id: taskId
        }
      };

      try {
        const res = await fetch("/api/delegate-task", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(body)
        });

        console.log("Requeue result:", await res.json());
      } catch (err) {
        console.error("Requeue failed:", err);
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
