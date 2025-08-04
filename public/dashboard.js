// --- Authentic Dashboard Logic with CSS Dots + Project Tracker w/ full timeline ---
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

async function fetchProjectTracker() {
  const res = await fetch("/api/project-tracker");
  const tasks = await res.json();
  const container = document.getElementById("project-tracker");
  if (!container) return;

  container.innerHTML = "";
  if (tasks.length === 0) {
    container.innerHTML = "<div class='empty'>No active tasks</div>";
    return;
  }

  tasks.forEach(t => {
    const div = document.createElement("div");
    div.className = `task ${t.status}`;
    if (t.status === "complete" && t.endTime) {
      div.textContent = `${t.task} — ${t.agent} (Complete, ${t.startTime} → ${t.endTime})`;
    } else {
      div.textContent = `${t.task} — ${t.agent} (${t.status}, started ${t.startTime})`;
    }
    container.appendChild(div);
  });
}

// Refresh every 5 seconds
setInterval(() => {
  fetchAgentStatus();
  fetchOpsStream();
  fetchProjectTracker();
}, 5000);

// Initial load
fetchAgentStatus();
fetchOpsStream();
fetchProjectTracker();
