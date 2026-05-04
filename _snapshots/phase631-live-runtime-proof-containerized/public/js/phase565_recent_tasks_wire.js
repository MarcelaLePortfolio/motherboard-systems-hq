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

  function statusClass(status) {
    const s = String(status || "").toLowerCase();
    if (s.includes("complete")) return "text-green-400";
    if (s.includes("running")) return "text-yellow-400";
    if (s.includes("queued")) return "text-blue-400";
    if (s.includes("failed")) return "text-red-400";
    return "text-gray-400";
  }

  function renderRecentTasks(tasks) {
    const mount = document.getElementById("recentTasks");
    if (!mount) return;

    mount.innerHTML = "";

    const items = Array.isArray(tasks) ? tasks.slice(0, 8) : [];

    if (items.length === 0) {
      mount.textContent = "No recent tasks yet.";
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
      meta.className = "mt-2 text-xs leading-5";

      const statusSpan = document.createElement("span");
      statusSpan.className = statusClass(task.status);
      statusSpan.textContent = text(task.status, "unknown");

      meta.appendChild(document.createTextNode("Status: "));
      meta.appendChild(statusSpan);
      meta.appendChild(document.createTextNode(" · Updated: " + formatTime(task.updated_at || task.created_at)));

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

  function startRecentTasksWire() {
    refreshRecentTasks();
}

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", startRecentTasksWire, { once: true });
  } else {
    startRecentTasksWire();
  }
})();
