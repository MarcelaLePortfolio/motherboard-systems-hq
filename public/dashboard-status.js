// --------------------------------------------------
// 🧠 Dashboard Status Logic — Live + Preload
// --------------------------------------------------
document.addEventListener("DOMContentLoaded", () => {
  console.log("📡 Initializing final SSE listener...");

  // 🧩 Preload latest agent statuses on dashboard load
  fetch("/agents/status")
    .then(res => res.json())
    .then(agents => {
      console.log("✅ Preloaded agent statuses:", agents);
      const container = document.getElementById("agentStatusContainer");
    if (container && !container.dataset.labeled) {
      const label = document.createElement("div");
      label.textContent = "🛰️ Live Agents";
      label.style.fontWeight = "600";
      label.style.marginBottom = "6px";
      label.style.color = "#00c8ff";
      label.style.textShadow = "0 0 6px #00c8ff";
      container.appendChild(label);
      container.dataset.labeled = "true";
    }
      if (container) {
        container.innerHTML = "";
        agents.forEach(agent => {
          const line = document.createElement("div");
          line.textContent = `${agent.name}: ${agent.status}`;
          line.style.margin = "2px 0";
        line.style.color =
          agent.status.includes("online") ? "#00ff7f" :
          agent.status.includes("busy") ? "#ffb84d" :
          "#ff6666";
        line.style.textShadow = "0 0 6px " + line.style.color;
          container.appendChild(line);
        });
      }
    })
    .catch(err => console.warn("⚠️ Could not preload statuses:", err));

  // 🛰️ Live SSE connection
  const evtSource = new EventSource("/events/agents");
  evtSource.onopen = () => console.log("✅ SSE connection established");
  evtSource.onerror = (err) => console.error("❌ SSE error:", err);

  evtSource.addEventListener("ping", () => console.debug("💓 ping"));
  evtSource.addEventListener("agent", (e) => {
    const data = JSON.parse(e.data);
    console.log("🤖 Live Agent Update:", data);
    const container = document.getElementById("agentStatusContainer");
    if (container && !container.dataset.labeled) {
      const label = document.createElement("div");
      label.textContent = "🛰️ Live Agents";
      label.style.fontWeight = "600";
      label.style.marginBottom = "6px";
      label.style.color = "#00c8ff";
      label.style.textShadow = "0 0 6px #00c8ff";
      container.appendChild(label);
      container.dataset.labeled = "true";
    }
    if (!container) return;
    container.innerHTML = "";
    if (Array.isArray(data.agents)) {
      data.agents.forEach(agent => {
        const line = document.createElement("div");
        line.textContent = `${agent.name}: ${agent.status}`;
        line.style.margin = "2px 0";
        line.style.color =
          agent.status.includes("online") ? "#00ff7f" :
          agent.status.includes("busy") ? "#ffb84d" :
          "#ff6666";
        line.style.textShadow = "0 0 6px " + line.style.color;
        container.appendChild(line);
      });
    }
  });
});
