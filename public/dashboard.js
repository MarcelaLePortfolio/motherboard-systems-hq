// --- Auto-refresh Dashboard Logic ---
async function fetchAgentStatus() {
  const res = await fetch("/api/agent-status");
  const data = await res.json();
  const container = document.getElementById("agent-status");
  if (!container) return;
  container.innerHTML = "";
  Object.keys(data).forEach((agent) => {
    const info = data[agent];
    const div = document.createElement("div");
    div.className = "agent";
    div.innerHTML = `
      <span class="agent-icon">${info.icon}</span>
      <strong>${agent}</strong><br>
      <small>${info.status} – ${new Date(info.lastPing).toLocaleTimeString()}</small>
    `;
    container.appendChild(div);
  });
}

async function fetchOpsStream() {
  const res = await fetch("/api/ops-stream");
  const data = await res.json();
  const container = document.getElementById("ops-stream");
  if (!container) return;
  container.innerHTML = "";
  data.slice().reverse().forEach((log) => {
    const div = document.createElement("div");
    div.className = "ops-log";
    div.textContent = `[${log.time}] ${log.message}`;
    container.appendChild(div);
  });
}

// Refresh every 3 seconds
setInterval(() => {
  fetchAgentStatus();
  fetchOpsStream();
}, 3000);

// Initial load
fetchAgentStatus();
fetchOpsStream();
