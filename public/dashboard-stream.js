if (!window.__DASHBOARD_SSE_INITIALIZED__) {
  window.__DASHBOARD_SSE_INITIALIZED__ = true;

  console.log("📡 Initializing final SSE listener...");

  const evtSource = new EventSource("http://localhost:3101/events/reflections");

  evtSource.onopen = () => console.log("✅ SSE connection established");
  evtSource.onerror = (err) => console.error("❌ SSE error:", err);

  evtSource.addEventListener("ping", () => {
    console.debug("💓 ping");
  });

  evtSource.addEventListener("agent", (e) => {
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
