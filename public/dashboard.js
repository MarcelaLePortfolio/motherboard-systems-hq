// --- Authentic Dashboard Logic with CSS Dots ---
let lastLog = "";

async function fetchAgentStatus() {
  const res = await fetch("/api/agent-status");
  const data = await res.json();
  const container = document.getElementById("agent-status");
  if (!container) return;

  container.innerHTML = "";
  const displayOrder = ["Matilda", "Cade", "Effie"];
  displayOrder.forEach((agent) => {
    const info = data[agent];
    if (!info) return;

    const div = document.createElement("div");
    div.className = "agent";

    const dot = document.createElement("span");
    dot.className = `status-dot ${info.status || "offline"}`;

    const name = document.createElement("strong");
    name.textContent = agent;

    div.appendChild(dot);
    div.appendChild(name);

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
