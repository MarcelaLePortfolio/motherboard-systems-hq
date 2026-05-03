// <0001fad2> Phase 4.9 — Dashboard OPS Stream Integration
const opsStream = new EventSource("http://localhost:3201/events/ops");

opsStream.onopen = () => console.log("🟢 OPS Stream connected");
opsStream.onerror = (e) => console.error("❌ OPS Stream error", e);

opsStream.onmessage = (e) => {
  try {
    const data = JSON.parse(e.data);
    updateRecentPanels(data);
  } catch (err) {
    console.error("⚠️ Invalid OPS payload:", e.data);
  }
};

function updateRecentPanels(data) {
  const logsContainer = document.getElementById("recent-logs");
  const tasksContainer = document.getElementById("recent-tasks");
  if (!logsContainer || !tasksContainer) return;

  const { reflections = [], tasks = [] } = data;
  logsContainer.innerHTML = reflections
    .map(r => `<li>${r.content} <span class="timestamp">${friendlyTime(r.created_at)}</span></li>`)
    .join("");
  tasksContainer.innerHTML = tasks
    .map(t => `<li>${t.description} <span class="timestamp">${friendlyTime(t.created_at)}</span></li>`)
    .join("");
}

function friendlyTime(ts) {
  const diff = (Date.now() - new Date(ts)) / 1000;
  if (diff < 60) return `${Math.floor(diff)}s ago`;
  if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
  if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
  return `${Math.floor(diff / 86400)}d ago`;
}
