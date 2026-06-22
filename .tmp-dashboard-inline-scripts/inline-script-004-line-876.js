(function () {
  function formatTimestamp(value) {
    if (!value) return "time unavailable";
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return String(value);
    return d.toLocaleString();
  }

  function normalizeStatus(value) {
    return String(value || "unknown").replace(/_/g, " ");
  }

  function taskSummary(task) {
    const title = String(task.title || "Untitled task");
    const status = normalizeStatus(task.status);
    const updated = formatTimestamp(task.updated_at || task.created_at);
    return { title, status, updated };
  }

  function renderTasks(tasks) {
    const mount = document.getElementById("tasks-widget");
    if (!mount) return;

    mount.innerHTML = "";

    const wrapper = document.createElement("div");
    wrapper.style.display = "grid";
    wrapper.style.gap = "10px";

    const items = Array.isArray(tasks) ? tasks.slice(0, 8) : [];

    if (items.length === 0) {
      const empty = document.createElement("div");
      empty.className = "rounded-xl border border-gray-700 bg-gray-900/60 p-4 text-sm text-gray-400";
      empty.textContent = "No recent tasks available.";
      wrapper.appendChild(empty);
      mount.appendChild(wrapper);
      return;
    }

    items.forEach((task) => {
      const summary = taskSummary(task);

      const card = document.createElement("div");
      card.className = "rounded-xl border border-gray-700 bg-gray-900/60 p-4";

      const title = document.createElement("div");
      title.className = "text-sm font-semibold text-gray-100";
      title.textContent = summary.title;

      const meta = document.createElement("div");
      meta.className = "mt-2 text-xs text-gray-400 leading-5";
      meta.innerHTML =
        "Status: " + summary.status + "<br>" +
        "Updated: " + summary.updated;

      card.appendChild(title);
      card.appendChild(meta);
      wrapper.appendChild(card);
    });

    mount.appendChild(wrapper);
  }

  async function refreshTasks() {
    try {
      const res = await fetch("/api/tasks", { cache: "no-store" });
      if (!res.ok) throw new Error("tasks fetch failed");
      const data = await res.json();
      renderTasks(Array.isArray(data.tasks) ? data.tasks : []);
    } catch (_) {
      renderTasks([]);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", refreshTasks, { once: true });
  } else {
    refreshTasks();
  }
})();
