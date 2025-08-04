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

// --- New: Fetch Task History for Tasks Tab ---
async function fetchTaskHistory() {
  const res = await fetch("/api/task-history");
  const events = await res.json();
  const container = document.getElementById("task-history");
  if (!container) return;

  container.innerHTML = "";
  if (events.length === 0) {
    container.innerHTML = "<div class='empty'>No task history yet</div>";
    return;
  }

  events.forEach(e => {
    const div = document.createElement("div");
    div.className = "task-event";
    div.textContent = `${e.time} | ${e.agent} ${e.event}`;
    container.appendChild(div);
  });
}

// Include in refresh loop
setInterval(() => {
  fetchAgentStatus();
  fetchOpsStream();
  fetchProjectTracker();
  fetchTaskHistory();
}, 5000);

// Initial call
fetchTaskHistory();

// Enhance task history color coding
function renderTaskEvent(e) {
  const div = document.createElement("div");
  div.className = "task-event";
  if (e.event.startsWith("completed-task")) div.classList.add("complete");
  if (e.event.startsWith("processing-task")) div.classList.add("progress");
  div.textContent = `${e.time} | ${e.agent} ${e.event}`;
  return div;
}

async function fetchTaskHistory() {
  const res = await fetch("/api/task-history");
  const events = await res.json();
  const container = document.getElementById("task-history");
  if (!container) return;

  container.innerHTML = "";
  if (events.length === 0) {
    container.innerHTML = "<div class='empty'>No task history yet</div>";
    return;
  }

  events.forEach(e => container.appendChild(renderTaskEvent(e)));
}

// --- Settings Tab Logic ---
async function fetchSettings() {
  const res = await fetch("/api/settings");
  const data = await res.json();
  const container = document.getElementById("settings-tab");
  if (!container) return;

  container.innerHTML = "";

  const title = document.createElement("h3");
  title.textContent = "Agent Runtime Controls";
  container.appendChild(title);

  data.agents.forEach(agent => {
    const div = document.createElement("div");
    div.className = "task"; // reuse styling
    div.textContent = `${agent.name} — ${agent.status}`;
    
    const startBtn = document.createElement("button");
    startBtn.textContent = "Start";
    startBtn.style.marginLeft = "8px";
    startBtn.onclick = () => controlAgent(agent.name, "start");

    const stopBtn = document.createElement("button");
    stopBtn.textContent = "Stop";
    stopBtn.style.marginLeft = "4px";
    stopBtn.onclick = () => controlAgent(agent.name, "stop");

    div.appendChild(startBtn);
    div.appendChild(stopBtn);

    container.appendChild(div);
  });

  const placeholder = document.createElement("div");
  placeholder.className = "empty";
  placeholder.textContent = "Future: log retention, theme toggle, direct restart commands.";
  container.appendChild(placeholder);
}

async function controlAgent(agent, action) {
  const res = await fetch("/api/agent-control", {
    method: "POST",
    headers: { "Content-Type":"application/json" },
    body: JSON.stringify({ agent, action })
  });
  const data = await res.json();
  alert(`${agent} ${action}: ${data.success ? "OK" : "Failed"}\n${data.message || ""}`);
  fetchSettings();
}

// Include in refresh loop
setInterval(() => {
  fetchAgentStatus();
  fetchOpsStream();
  fetchProjectTracker();
  fetchTaskHistory();
  fetchSettings();
}, 5000);

fetchSettings();

// --- Update Settings UI with Restart Button ---
async function fetchSettings() {
  const res = await fetch("/api/settings");
  const data = await res.json();
  const container = document.getElementById("settings-tab");
  if (!container) return;

  container.innerHTML = "";

  const title = document.createElement("h3");
  title.textContent = "Agent Runtime Controls";
  container.appendChild(title);

  data.agents.forEach(agent => {
    const div = document.createElement("div");
    div.className = "task"; 
    div.textContent = `${agent.name} — ${agent.status}`;

    const startBtn = document.createElement("button");
    startBtn.textContent = "Start";
    startBtn.style.marginLeft = "8px";
    startBtn.onclick = () => controlAgent(agent.name, "start");

    const stopBtn = document.createElement("button");
    stopBtn.textContent = "Stop";
    stopBtn.style.marginLeft = "4px";
    stopBtn.onclick = () => controlAgent(agent.name, "stop");

    const restartBtn = document.createElement("button");
    restartBtn.textContent = "Restart";
    restartBtn.style.marginLeft = "4px";
    restartBtn.onclick = () => controlAgent(agent.name, "restart");

    div.appendChild(startBtn);
    div.appendChild(stopBtn);
    div.appendChild(restartBtn);

    container.appendChild(div);
  });

  const placeholder = document.createElement("div");
  placeholder.className = "empty";
  placeholder.textContent = "Future: log retention, theme toggle, and auto-scroll settings.";
  container.appendChild(placeholder);
}
