if (!window.__DASHBOARD_SSE_INITIALIZED__) {
  window.__DASHBOARD_SSE_INITIALIZED__ = true;
// Function to add a single line log to the specified container
const addLogLine = (containerId, message, color = 'white') => {
    const container = document.getElementById(containerId);
    if (container) {
        const line = document.createElement("div");
        line.textContent = `[${new Date().toLocaleTimeString()}] ${message}`;
        line.style.margin = "2px 0";
        line.style.color = color;
        // Prepend the new log line to show newest first
        container.prepend(line); 
    } else {
        console.warn(`⚠️ Log container #${containerId} not found.`);
    }
};

// --- 1. Agent Status Stream (/api/agent-status-stream) ---
console.log("📡 Initializing Agent Status Stream (/api/agent-status-stream)...");
// Note: Assumes Agent Status endpoint is on the new, correct path.
const agentSource = new EventSource("/api/agent-status-stream");

agentSource.onopen = () => console.log("✅ Agent Stream connection established");
agentSource.onerror = (err) => console.error("❌ Agent Stream error:", err);

agentSource.addEventListener("agent", (e) => {
    const data = JSON.parse(e.data);
    console.log("🤖 Live Agent Update:", data);

    const container = document.getElementById("agentStatusContainer");
    if (!container) {
        console.warn("⚠️ No #agentStatusContainer found in DOM");
        return;
    }

    container.innerHTML = "";
    if (Array.isArray(data.agents)) {
        data.agents.forEach(agent => {
            const line = document.createElement("div");
            line.textContent = `${agent.name}: ${agent.status}`;
            line.style.margin = "2px 0";
            line.style.color =
                agent.status.includes("online") ? "#55ff55" :
                agent.status.includes("busy") ? "#ffaa00" :
                "#ff5555";
            container.appendChild(line);
        });
    } else {
        container.textContent = "⚠️ No agents array in event data";
    }
});

// --- 2. Reflection Stream (/api/reflection-stream) ---
console.log("�� Initializing Reflection Stream (/api/reflection-stream)...");
const reflectionSource = new EventSource("/api/reflection-stream");

reflectionSource.onopen = () => console.log("✅ Reflection Stream connection established");
reflectionSource.onerror = (err) => console.error("❌ Reflection Stream error:", err);

reflectionSource.addEventListener("reflectionUpdate", (e) => {
    const reflection = JSON.parse(e.data);
    console.log("💡 New Reflection:", reflection);
    
    // Logs reflections to a container we assume exists in the UI
    addLogLine('reflectionLogContainer', `[TICKET ${reflection.ticket_id}] ${reflection.message}`, '#cccccc');
});

// --- 3. Task Stream (From P1, listens on /api/task-stream) ---
console.log("📡 Initializing Task Stream (/api/task-stream)...");
const taskSource = new EventSource("/api/task-stream");

taskSource.onopen = () => console.log("✅ Task Stream connection established");
taskSource.onerror = (err) => console.error("❌ Task Stream error:", err);

taskSource.addEventListener("taskUpdate", (e) => {
    const taskEvent = JSON.parse(e.data);
    console.log("🛠️ New Task Event:", taskEvent);
    
    let color = '#ffffff';
    if (taskEvent.status === 'completed') color = '#55ff55';
    else if (taskEvent.status === 'failed') color = '#ff5555';
    else if (taskEvent.status === 'started') color = '#00ffff'; 
    else if (taskEvent.status === 'acknowledged') color = '#ffaa00'; 

    // Logs task events to a container we assume exists in the UI
    addLogLine('taskLogContainer', `TASK ${taskEvent.task_id} (${taskEvent.agent}): Status changed to ${taskEvent.status}.`, color);
});

  console.log("📡 Initializing final SSE listener...");

    const data = JSON.parse(e.data);
    console.log("🤖 Live Agent Update:", data);

    const container = document.getElementById("agentStatusContainer");
    if (!container) {
      console.warn("⚠️ No #agentStatusContainer found in DOM");
      return;
    }

    container.innerHTML = "";
    if (Array.isArray(data.agents)) {
      data.agents.forEach(agent => {
        const line = document.createElement("div");
        line.textContent = `${agent.name}: ${agent.status}`;
        line.style.margin = "2px 0";
        line.style.color =
          agent.status.includes("online") ? "#55ff55" :
          agent.status.includes("busy") ? "#ffaa00" :
          "#ff5555";
        container.appendChild(line);
      });
    } else {
      container.textContent = "⚠️ No agents array in event data";
    }
  });
}
