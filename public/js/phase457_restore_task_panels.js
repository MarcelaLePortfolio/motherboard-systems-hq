/* Path A — Retry Differently (CLEAN IMPLEMENTATION)
   Single event delegation, no observers, no globals, no stacking */

(function () {
  document.body.addEventListener("click", async (e) => {
    const el = e.target.closest('[data-action="retry-different"]');
    if (!el) return;

    console.log("[retry-different][clean] click detected");

    const row = el.closest("[data-task-id]");
    if (!row) {
      console.warn("[retry-different][clean] no task row found");
      return;
    }

    const body = {
      title: row.getAttribute("data-title") || "Retry task",
      source: "execution-inspector",
      kind: "retry-strategy",
      notes: "Retry with alternative approach",
      meta: {
        retry_mode: "strategy_shift",
        strategy_applied: "prompt_augmentation",
        retry_of_task_id: row.getAttribute("data-task-id"),
        retry_of_event_id: row.getAttribute("data-id"),
        retry_of_kind: "inspector-row",
        instruction: "Use a different execution strategy than previous attempt"
      }
    };

    try {
      const res = await fetch("/api/delegate-task", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
      });

      const data = await res.json();
      console.log("[retry-different][clean] queued:", data);
    } catch (err) {
      console.error("[retry-different][clean] failed:", err);
    }
  });
})();
