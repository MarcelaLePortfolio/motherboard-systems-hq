if (!window.__DASHBOARD_SSE_INITIALIZED__) {
  window.__DASHBOARD_SSE_INITIALIZED__ = true;
  console.log("📡 Initializing SSE listener...");

  // === Primary Agent Stream ===
  const agentSource = new EventSource("/events/agents");

  agentSource.onopen = () => console.log("✅ SSE connection established");
  agentSource.onerror = (err) => console.error("❌ SSE error:", err);

  agentSource.addEventListener("ping", () => console.debug("💓 ping"));
  agentSource.addEventListener("agent", (e) => {
    const data = JSON.parse(e.data);
    const container = document.getElementById("agentStatusContainer");
    if (!container) return;
    container.innerHTML = "";
    if (Array.isArray(data.agents)) {
      data.agents.forEach(agent => {
        const row = document.createElement("div");
        row.textContent = `${agent.name}: ${agent.status} (${agent.uptime})`;
        container.appendChild(row);
      });
    }
  });

  // === Recent Tasks Stream ===
  const taskSource = new EventSource("/events/tasks");
  taskSource.onmessage = (e) => {
    const data = JSON.parse(e.data);
    const container = document.getElementById("recentTasks");
    if (!container) return;
    container.innerHTML = "";
    if (Array.isArray(data.tasks) && data.tasks.length) {
      data.tasks.forEach(task => {
        const row = document.createElement("div");
        row.textContent = `🧩 ${task.type || "Task"} — ${task.status}`;
        container.appendChild(row);
      });
    } else {
      container.innerHTML = "<i style='color:#555;'>Nothing yet — waiting for activity.</i>";
    }
  };

  // === Recent Logs Stream ===
  const logSource = new EventSource("/events/logs");
  logSource.onmessage = (e) => {
    const data = JSON.parse(e.data);
    const container = document.getElementById("recentLogs");
    if (!container) return;
    container.innerHTML = "";
    if (Array.isArray(data.logs) && data.logs.length) {
      data.logs.slice(-10).forEach(log => {
        const row = document.createElement("div");
        row.textContent = `📜 ${log.message || JSON.stringify(log)}`;
        container.appendChild(row);
      });
    } else {
      container.innerHTML = "<i style='color:#555;'>Nothing yet — waiting for logs.</i>";
    }
  };
}
