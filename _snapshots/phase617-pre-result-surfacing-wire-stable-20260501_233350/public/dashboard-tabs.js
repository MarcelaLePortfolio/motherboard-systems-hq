 
// --- Enhanced Tab Wiring with Guaranteed First-Run & Console Debugging ---

// 1️⃣ Project Tracker Tab
async function fetchProjectTracker() {
  const container = document.getElementById("project-tracker");
  if (!container) {
    console.warn("⚠️ Project Tracker container #project-tracker not found.");
    return;
  }

  try {
    const res = await fetch("/api/project-tracker");
    const tasks = await res.json();

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
  } catch (err) {
    console.error("❌ Failed to fetch Project Tracker:", err);
    container.innerHTML = "<div class='empty'>Error loading Project Tracker</div>";
  }
}

// 2️⃣ Task History Tab
function renderTaskEvent(e) {
  const div = document.createElement("div");
  div.className = "task-event";
  if (e.event.startsWith("completed-task")) div.classList.add("complete");
  if (e.event.startsWith("processing-task")) div.classList.add("progress");
  div.textContent = `${e.time} | ${e.agent} ${e.event}`;
  return div;
}

async function fetchTaskHistory() {
  const container = document.getElementById("task-history");
  if (!container) {
    console.warn("⚠️ Task History container #task-history not found.");
    return;
  }

  try {
    const res = await fetch("/api/task-history");
    const events = await res.json();

    container.innerHTML = "";
    if (events.length === 0) {
      container.innerHTML = "<div class='empty'>No task history yet</div>";
      return;
    }

    events.forEach(e => container.appendChild(renderTaskEvent(e)));
  } catch (err) {
    console.error("❌ Failed to fetch Task History:", err);
    container.innerHTML = "<div class='empty'>Error loading Task History</div>";
  }
}

// 3️⃣ Settings Tab
async function controlAgent(agent, action) {
  try {
    const res = await fetch("/api/agent-control", {
      method: "POST",
      headers: { "Content-Type":"application/json" },
      body: JSON.stringify({ agent, action })
    });
    const data = await res.json();
    alert(`${agent} ${action}: ${data.success ? "OK" : "Failed"}
${data.message || ""}`);
    fetchSettings();
  } catch (err) {
    alert(`${agent} ${action} failed: ${err.message}`);
  }
}

async function fetchSettings() {
  const container = document.getElementById("settings-tab");
  if (!container) {
    console.warn("⚠️ Settings container #settings-tab not found.");
    return;
  }

  try {
    const res = await fetch("/api/settings");
    const data = await res.json();

    container.innerHTML = "";

    const title = document.createElement("h3");
    title.textContent = "Agent Runtime Controls";
    container.appendChild(title);

    data.agents.forEach(agent => {
      const div = document.createElement("div");
      div.className = "task"; 
      div.textContent = `${agent.name} — ${agent.status}`;

      const isOnline = agent.status.toLowerCase() === "online";

      const startBtn = document.createElement("button");
      startBtn.textContent = "Start";
      startBtn.style.marginLeft = "8px";
      startBtn.disabled = isOnline;
      startBtn.onclick = () => controlAgent(agent.name, "start");

      const stopBtn = document.createElement("button");
      stopBtn.textContent = "Stop";
      stopBtn.style.marginLeft = "4px";
      stopBtn.disabled = !isOnline;
      stopBtn.onclick = () => controlAgent(agent.name, "stop");

      const restartBtn = document.createElement("button");
      restartBtn.textContent = "Restart";
      restartBtn.style.marginLeft = "4px";
      restartBtn.disabled = !isOnline;
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
  } catch (err) {
    console.error("❌ Failed to fetch Settings:", err);
    container.innerHTML = "<div class='empty'>Error loading Settings</div>";
  }
}

// 4️⃣ Unified Refresh Loop
function refreshAllTabs() {
  fetchAgentStatus?.();
  fetchOpsStream?.();
  fetchProjectTracker();
  fetchTaskHistory();
  fetchSettings();
}

// Refresh every 5 seconds
setInterval(refreshAllTabs, 5000);

// ✅ Guaranteed first-run on page load
refreshAllTabs();

// 5️⃣ Trigger Settings Tab Refresh on Click
document.querySelectorAll(".tab[data-tab='settings']").forEach(tab => {
  tab.addEventListener("click", () => {
    fetchSettings();
  });
});
