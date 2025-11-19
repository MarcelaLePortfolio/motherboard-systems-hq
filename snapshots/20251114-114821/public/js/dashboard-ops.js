const opsStream = new EventSource("http://localhost:3201/events/ops");

opsStream.onopen = () => console.log("🟢 OPS Stream connected");
opsStream.onerror = (e) => console.error("❌ OPS Stream error", e);

opsStream.onmessage = (e) => {
  try {
    const data = JSON.parse(e.data);
    console.log("📡 OPS update received:", data);

    // Update Recent Tasks
    const tasksContainer = document.getElementById("recentTasks");
    if (tasksContainer && data.tasks) {
      tasksContainer.innerHTML = data.tasks
        .map(
          (t) => `
          <div class="task-entry">
            <strong>${t.description}</strong>
            <span class="status">${t.status}</span>
            <small>${new Date(t.created_at).toLocaleTimeString()}</small>
          </div>`
        )
        .join("");
    }

    // Update Recent Logs (from reflections)
    const logsContainer = document.getElementById("recentLogs");
    if (logsContainer && data.reflections) {
      logsContainer.innerHTML = data.reflections
        .map(
          (r) => `
          <div class="log-entry">
            <span>${r.content}</span>
            <small>${new Date(r.created_at).toLocaleTimeString()}</small>
          </div>`
        )
        .join("");
    }
  } catch (err) {
    console.error("⚠️ OPS Stream parse error:", err);
  }
};
