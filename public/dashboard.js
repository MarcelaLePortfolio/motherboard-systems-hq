// --- Polished Auto-Refresh Dashboard Logic ---
let lastLog = "";

async function fetchAgentStatus() {
  const res = await fetch("/api/agent-status");
  const data = await res.json();
  const container = document.getElementById("agent-status");
  if (!container) return;

  container.innerHTML = "";
  Object.keys(data).forEach((agent) => {
    const info = data[agent];
    const div = document.createElement("div");
    div.className = `agent ${info.status}`;
    div.innerHTML = `
      <span class="agent-icon">${info.icon}</span>
      <strong>${agent}</strong>
      <small>${info.status}</small>
    `;
    container.appendChild(div);
  });
}

async function fetchOpsStream() {
  const res = await fetch("/api/ops-stream");
  const data = await res.json();
  const container = document.getElementById("ops-stream");
  if (!container) return;

  const latest = data[data.length - 1]?.message || "";
  if (latest && latest !== lastLog) {
    lastLog = latest;
    container.innerHTML = `<div class="ops-log">${latest}</div>`;
  }
}

// Refresh every 3 seconds
setInterval(() => {
  fetchAgentStatus();
  fetchOpsStream();
}, 3000);

// Initial load
fetchAgentStatus();
fetchOpsStream();
