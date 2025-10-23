if (!window.__DASHBOARD_SSE_INITIALIZED__) {
  window.__DASHBOARD_SSE_INITIALIZED__ = true;

console.log("📡 Initializing heartbeat-enhanced dashboard SSE listener...");

const evtSource = new EventSource("/events/agents");

// 🎨 Status + Log Containers
const statusEl = document.getElementById("connectionStatus") || (() => {
  const el = document.createElement("div");
  el.id = "connectionStatus";
  el.style = `
    position: fixed;
    bottom: 8px;
    right: 12px;
    padding: 6px 10px;
    border-radius: 6px;
    background: #222;
    color: #0f0;
    font-size: 12px;
    font-family: monospace;
    z-index: 9999;
    display: flex;
    align-items: center;
    gap: 6px;
  `;
  el.innerHTML = '<span id="heartbeat" style="width:10px;height:10px;border-radius:50%;background:#0f0;display:inline-block;box-shadow:0 0 4px #0f0;"></span> <span id="statusText">🟡 Connecting...</span>';
  document.body.appendChild(el);
  return el;
})();

const heartbeatEl = document.getElementById("heartbeat");
const statusText = document.getElementById("statusText");

const logContainer = document.getElementById("logOutput") || (() => {
  const el = document.createElement("div");
  el.id = "logOutput";
  el.style = "font-family:monospace;white-space:pre-wrap;padding:10px;max-height:70vh;overflow-y:auto;";
  document.body.appendChild(el);
  return el;
})();

// ✅ Connection events
evtSource.onopen = () => {
  console.log("✅ SSE connection established");
  statusText.textContent = "🟢 Connected";
  heartbeatEl.style.background = "#0f0";
};

evtSource.onerror = (err) => {
  console.error("❌ SSE error:", err);
  statusText.textContent = "🔴 Disconnected";
  heartbeatEl.style.background = "#f33";
};

// 💓 Ping listener with pulsing heartbeat
evtSource.addEventListener("ping", () => {
  statusText.textContent = "💓 Active";
  heartbeatEl.animate(
    [
      { transform: "scale(1)", boxShadow: "0 0 4px #0f0" },
      { transform: "scale(1.5)", boxShadow: "0 0 12px #0f0" },
      { transform: "scale(1)", boxShadow: "0 0 4px #0f0" },
    ],
    { duration: 600, easing: "ease-in-out" }
  );
  setTimeout(() => {
    statusText.textContent = "🟢 Connected";
  }, 2000);
});

// 📝 Log events with color coding + auto-scroll
evtSource.addEventListener("log", (e) => {
  const data = JSON.parse(e.data);
  const line = document.createElement("div");
  const message = `[${data.time}] ${data.source}: ${data.message}`;

  if (/error|fail|exception/i.test(message)) {
    line.style.color = "#ff5555";
  } else if (/warn|⚠️|slow/i.test(message)) {
    line.style.color = "#ffaa00";
  } else if (/success|ok|verified|✅/i.test(message)) {
    line.style.color = "#55ff55";
  } else {
    line.style.color = "#cccccc";
  }

  line.textContent = message;
  logContainer.appendChild(line);
  logContainer.scrollTop = logContainer.scrollHeight;

  console.log("<0001fab9> Log event:", data);
});

// 🤖 Agent events
evtSource.addEventListener("agent", (e) => {
  const data = JSON.parse(e.data);
  console.log("🤖 Agent update:", data);
});

// 🔄 Live Agent Status Updates
evtSource.addEventListener("agent", (e) => {
  const data = JSON.parse(e.data);
  console.log("🤖 Live Agent Update:", data);

  const container = document.getElementById("agentStatusContainer");
  if (!container) return;

  container.innerHTML = "";
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
});
}
