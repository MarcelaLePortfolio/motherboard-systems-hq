(function () {
  function text(value, fallback) {
    return String(value || fallback || "").trim();
  }

  function formatTime(value) {
    if (!value) return "time unavailable";
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return String(value);
    return d.toLocaleString();
  }

  function renderRecentTasks(tasks) {
    const mount = document.getElementById("recentTasks");
    if (!mount) return;

    mount.setAttribute("data-phase565-recent-tasks-wire", "active");
    mount.innerHTML = "";

    const items = Array.isArray(tasks) ? tasks.slice(0, 8) : [];

    if (items.length === 0) {
      mount.textContent = "Phase 565 live tasks wire active — no recent tasks available.";
      return;
    }

    const list = document.createElement("div");
    list.style.display = "grid";
    list.style.gap = "0.75rem";

    items.forEach(function (task) {
      const card = document.createElement("div");
      card.className = "rounded-lg border border-gray-700 bg-gray-950/60 p-3";

      const title = document.createElement("div");
      title.className = "text-sm font-semibold text-gray-100";
      title.textContent = text(task.title || task.task_id || task.id, "Untitled task");

      const meta = document.createElement("div");
      meta.className = "mt-2 text-xs text-gray-400 leading-5";
      meta.textContent =
        "Status: " + text(task.status, "unknown") +
        " · Updated: " + formatTime(task.updated_at || task.created_at);

      card.appendChild(title);
      card.appendChild(meta);
      list.appendChild(card);
    });

    mount.appendChild(list);
  }

  async function refreshRecentTasks() {
    try {
      const res = await fetch("/api/tasks", { cache: "no-store" });
      if (!res.ok) throw new Error("tasks fetch failed");
      const data = await res.json();
      renderRecentTasks(Array.isArray(data.tasks) ? data.tasks : []);
    } catch (_) {
      renderRecentTasks([]);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", refreshRecentTasks, { once: true });
  } else {
    refreshRecentTasks();
  }
})();
