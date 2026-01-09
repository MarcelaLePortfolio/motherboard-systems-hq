(function () {
  if (window.__PHASE23_DELEGATE_TASKSPEC_STARTED) return;
  window.__PHASE23_DELEGATE_TASKSPEC_STARTED = true;

  async function delegate(taskSpec) {
    const task = taskSpec?.task ? taskSpec.task : taskSpec;
    const res = await fetch("/api/tasks-mutations/delegate-taskspec", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ task }),
    });
    const json = await res.json().catch(() => ({}));
    if (!res.ok || !json.ok) throw new Error(json.error || "delegate_failed");
    return json;
  }

  window.__MATILDA_DELEGATE_TASKSPEC = async (taskSpec) => {
    const out = await delegate(taskSpec);
    const tid = out?.task?.id ?? out?.task_id ?? "?";
    const fn = window.__MATILDA_CHAT_APPEND_SYSTEM || window.__chatAppendSystem || null;
    if (typeof fn === "function") {
      try { fn(`📨 delegated → task.queued [${tid}]`); } catch (_) {}
    }
    return out;
  };
})();
