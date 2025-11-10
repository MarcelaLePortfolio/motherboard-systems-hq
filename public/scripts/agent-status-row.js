// <0001fb95> Phase 9.17 — Agent Status Row Reintegration (Matilda, Cade, Effie, OPS, Reflections)
document.addEventListener("DOMContentLoaded", () => {
  const agents = ["Matilda", "Cade", "Effie", "OPS", "Reflections"];
  const container = document.createElement("div");
  container.id = "agentStatusRow";
  container.innerHTML = agents.map(name => `
    <div class="agent-tile" data-agent="${name}">
      <span class="agent-name">${name}</span>
      <span class="agent-dot"></span>
    </div>
  `).join("");
  document.body.prepend(container);

  function updateAgentStatus(name, status) {
    const tile = document.querySelector(\`.agent-tile[data-agent="\${name}"]\`);
    if (!tile) return;
    const dot = tile.querySelector(".agent-dot");
    dot.className = \`agent-dot status-\${status}\`;
  }

  // Try live SSE connection first
  try {
    const evtSource = new EventSource("http://localhost:3101/events/agents");
    evtSource.onmessage = (e) => {
      const data = JSON.parse(e.data);
      for (const [name, status] of Object.entries(data)) {
        updateAgentStatus(name, status);
      }
    };
    evtSource.onerror = () => console.warn("⚠️ SSE stream unavailable — fallback polling activated");
    evtSource.onopen = () => console.log("🟢 Connected to live agent SSE");
  } catch {
    console.warn("⚠️ SSE connection failed — enabling polling mode");
  }

  // Fallback polling (every 1s)
  setInterval(async () => {
    try {
      const res = await fetch("/health");
      const data = await res.json();
      for (const name of agents) {
        const status = data[name]?.online ? "online" : "offline";
        updateAgentStatus(name, status);
      }
    } catch {
      agents.forEach(name => updateAgentStatus(name, "offline"));
    }
  }, 1000);
});
