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
      <h2 class="text-xl font-semibold border-b border-gray-700 pb-2 mb-4">Agent Pool</h2>
      <div style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:0.9rem;width:100%;">
        ${(rows || []).map((agent) => `
          <div style="min-height:5.4rem;border:1px solid rgba(75,85,99,.9);background:rgba(17,24,39,.72);border-radius:1rem;padding:1rem;display:flex;flex-direction:column;justify-content:space-between;">
            <div>
              <div style="font-weight:800;color:#e5e7eb;font-size:1rem;line-height:1.2;">${esc(agent.agent_name)}</div>
              <div style="font-size:.82rem;color:#94a3b8;margin-top:.35rem;">${esc(agent.status)}</div>
            </div>
            <div style="font-size:.84rem;color:#cbd5e1;margin-top:.65rem;">${esc(agent.current_task || "Available")}</div>
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
      <div style="border-bottom:1px solid rgba(51,65,85,.7);padding:.55rem 0;">
        <div style="color:#e5e7eb;font-size:.86rem;font-weight:650;">${esc(task.title || task.task_id || "Untitled task")}</div>
        <div style="color:#94a3b8;font-size:.74rem;margin-top:.2rem;">
          status=${esc(task.status || "unknown")} · id=${esc(task.task_id || task.id || "—")}
        </div>
      </div>
    `).join("");
  }

  function renderRecent(tasks) {
    const recentTasks = document.getElementById("recentTasks");
    const recentLogs = document.getElementById("recentLogs");
    const recentCard = document.getElementById("recent-tasks-card");

    if (recentCard) {
      recentCard.style.display = "grid";
      recentCard.style.gridTemplateRows = "1fr 1fr";
      recentCard.style.gap = "1rem";
      recentCard.style.minHeight = "0";
      recentCard.style.height = "100%";
    }

    [recentTasks, recentLogs].forEach((el) => {
      if (!el) return;
      el.style.minHeight = "0";
      el.style.height = "100%";
      el.style.overflow = "auto";
      el.style.display = "block";
    });

    if (recentTasks) recentTasks.innerHTML = taskRows(tasks);

    if (recentLogs) {
      recentLogs.innerHTML = (tasks && tasks.length)
        ? tasks.map((task) => `
            <div style="border-bottom:1px solid rgba(51,65,85,.55);padding:.5rem 0;color:#cbd5e1;font-size:.8rem;">
              ${esc(task.updated_at || task.created_at || "time unavailable")} · ${esc(task.status || "unknown")} · ${esc(task.title || task.task_id || "Untitled task")}
            </div>
          `).join("")
        : `<div style="color:#94a3b8;font-size:.8rem;">No task history yet.</div>`;
    }
  }

  function renderActivity(rows) {
    const canvas = document.getElementById("task-activity-graph");
    if (!canvas || !window.Chart) return;

    const card = document.getElementById("task-activity-card");
    const shell = canvas.parentElement;

    if (card) {
      card.style.height = "100%";
      card.style.minHeight = "0";
      card.style.display = "flex";
      card.style.flexDirection = "column";
    }

    if (shell) {
      shell.style.flex = "1 1 auto";
      shell.style.height = "100%";
      shell.style.minHeight = "0";
      shell.style.display = "flex";
      shell.style.padding = "0.75rem";
    }

    canvas.style.flex = "1 1 auto";
    canvas.style.width = "100%";
    canvas.style.height = "100%";
    canvas.style.minHeight = "0";

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
      window.__PHASE530_ACTIVITY_CHART__.resize();
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
        resizeDelay: 0,
        layout: {
          padding: 8
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              precision: 0
            }
          }
        }
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
