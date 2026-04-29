(function () {
  if (window.__PHASE530_VISIBLE_PANELS_BRIDGE__) return;
  window.__PHASE530_VISIBLE_PANELS_BRIDGE__ = true;

  const POLL_MS = 10000;

  function esc(value) {
    return String(value ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;");
  }

  async function getJson(url) {
    const res = await fetch(url, { cache: "no-store" });
    const data = await res.json();
    if (!res.ok) throw new Error(data?.error || "Request failed");
    return data;
  }

  function renderAgents(rows) {
    const root = document.getElementById("agent-status-container");
    if (!root) return;

    root.innerHTML = `
      <h2 class="text-xl font-semibold border-b border-gray-700 pb-2 mb-3">Agent Pool</h2>
      <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:0.65rem;">
        ${(rows || []).map((agent) => `
          <div style="border:1px solid rgba(75,85,99,.9);background:rgba(17,24,39,.72);border-radius:.85rem;padding:.75rem;">
            <div style="font-weight:700;color:#e5e7eb;">${esc(agent.agent_name)}</div>
            <div style="font-size:.78rem;color:#94a3b8;margin-top:.2rem;">${esc(agent.status)}</div>
            <div style="font-size:.78rem;color:#cbd5e1;margin-top:.35rem;">${esc(agent.current_task || "Available")}</div>
          </div>
        `).join("")}
      </div>
    `;
  }

  function taskRows(tasks) {
    if (!tasks || !tasks.length) {
      return `<div style="color:#94a3b8;font-size:.8rem;">No recent tasks yet.</div>`;
    }

    return tasks.map((task) => `
      <div style="border-bottom:1px solid rgba(51,65,85,.7);padding:.45rem 0;">
        <div style="color:#e5e7eb;font-size:.82rem;font-weight:600;">${esc(task.title || task.task_id || "Untitled task")}</div>
        <div style="color:#94a3b8;font-size:.72rem;margin-top:.15rem;">
          status=${esc(task.status || "unknown")} · id=${esc(task.task_id || task.id || "—")}
        </div>
      </div>
    `).join("");
  }

  function renderRecent(tasks) {
    const recentTasks = document.getElementById("recentTasks");
    const recentLogs = document.getElementById("recentLogs");

    if (recentTasks) recentTasks.innerHTML = taskRows(tasks);

    if (recentLogs) {
      recentLogs.innerHTML = (tasks && tasks.length)
        ? tasks.map((task) => `
            <div style="border-bottom:1px solid rgba(51,65,85,.55);padding:.4rem 0;color:#cbd5e1;font-size:.78rem;">
              ${esc(task.updated_at || task.created_at || "time unavailable")} · ${esc(task.status || "unknown")} · ${esc(task.title || task.task_id || "Untitled task")}
            </div>
          `).join("")
        : `<div style="color:#94a3b8;font-size:.8rem;">No task history yet.</div>`;
    }
  }

  function renderActivity(rows) {
    const canvas = document.getElementById("task-activity-graph");
    if (!canvas || !window.Chart) return;

    const labels = (rows || []).map((row) => {
      const d = new Date(row.timestamp || Date.now());
      return Number.isNaN(d.getTime()) ? "now" : d.toLocaleTimeString();
    });

    const created = (rows || []).map((row) => Number(row.created_count || 0));
    const completed = (rows || []).map((row) => Number(row.completed_count || 0));
    const failed = (rows || []).map((row) => Number(row.failed_count || 0));

    if (window.__PHASE530_ACTIVITY_CHART__) {
      window.__PHASE530_ACTIVITY_CHART__.data.labels = labels;
      window.__PHASE530_ACTIVITY_CHART__.data.datasets[0].data = created;
      window.__PHASE530_ACTIVITY_CHART__.data.datasets[1].data = completed;
      window.__PHASE530_ACTIVITY_CHART__.data.datasets[2].data = failed;
      window.__PHASE530_ACTIVITY_CHART__.update();
      return;
    }

    window.__PHASE530_ACTIVITY_CHART__ = new Chart(canvas, {
      type: "line",
      data: {
        labels,
        datasets: [
          { label: "Created", data: created },
          { label: "Completed", data: completed },
          { label: "Failed", data: failed }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: { y: { beginAtZero: true } }
      }
    });
  }

  async function refresh() {
    try {
      const agents = await getJson("/api/agents");
      renderAgents(Array.isArray(agents) ? agents : []);
    } catch (e) {
      console.warn("[phase530] agents render failed", e);
    }

    try {
      const data = await getJson("/api/tasks?limit=12");
      renderRecent(data.tasks || []);
    } catch (e) {
      console.warn("[phase530] recent tasks render failed", e);
    }

    try {
      const activity = await getJson("/api/activity-graph");
      renderActivity(Array.isArray(activity) ? activity : []);
    } catch (e) {
      console.warn("[phase530] activity graph render failed", e);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", refresh, { once: true });
  } else {
    refresh();
  }

  setInterval(refresh, POLL_MS);
})();
