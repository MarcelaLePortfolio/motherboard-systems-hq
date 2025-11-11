// <0001fd20> Phase 10.9.5 — Agent Status Live Monitor (SSE + fallback polling)
document.addEventListener("DOMContentLoaded", () => {
  const stabilityAgents = ["OPS", "Reflections"];
  const coreAgents = ["Matilda", "Cade", "Effie"];
  const allAgents = [...stabilityAgents, ...coreAgents];

  function renderTiles(agents, containerId, labelClass) {
    const container = document.getElementById(containerId);
    if (!container) return;
    container.innerHTML = agents.map(
      (a) => `<div class="agent-tile ${labelClass}" data-agent="${a}">
                <div class="agent-dot status-offline"></div>
                <span class="agent-label">${a}</span>
              </div>`
    ).join("");
  }

  renderTiles(stabilityAgents, "stabilityRow", "agent-stability");
  renderTiles(coreAgents, "agentStatusRow", "agent-core");

  function updateAgentStatus(name, status) {
    const tile = document.querySelector(\`.agent-tile[data-agent="\${name}"] .agent-dot\`);
    if (!tile) return;
    tile.className = \`agent-dot status-\${status}\`;
  }

  let connected = false;
  try {
    const evtSource = new EventSource("http://localhost:3101/events/agents");
    evtSource.onopen = () => console.log("<0001fa9e> Connected to agent SSE feed");
    evtSource.onmessage = (e) => {
      connected = true;
      try {
        const data = JSON.parse(e.data);
        for (const [name, state] of Object.entries(data)) {
          updateAgentStatus(name, state === "online" ? "online" : "offline");
        }
      } catch (err) {
        console.warn("⚠️ SSE parse error:", err);
      }
    };
    evtSource.onerror = () => {
      connected = false;
      console.warn("⚠️ SSE connection lost — switching to fallback polling");
    };
  } catch {
    console.warn("⚠️ Failed to connect to SSE — enabling fallback");
  }

  // Fallback polling (1 Hz)
  setInterval(async () => {
    if (connected) return;
    try {
      const res = await fetch("/health");
      if (!res.ok) throw new Error("Health check failed");
      const data = await res.json();
      allAgents.forEach((name) => {
        const online = data[name]?.online ?? false;
        updateAgentStatus(name, online ? "online" : "offline");
      });
    } catch {
      allAgents.forEach((n) => updateAgentStatus(n, "offline"));
    }
  }, 1000);
});
