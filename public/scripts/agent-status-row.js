// <0001fb95> Phase 9.17/9.18 — Agent + Stability Status Rows (SSE + polling fallback)
document.addEventListener("DOMContentLoaded", () => {
  const coreAgents = ["Matilda", "Cade", "Effie"];
  const stabilityAgents = ["OPS", "Reflections"];
  const allAgents = [...coreAgents, ...stabilityAgents];

  const container = document.createElement("div");
  container.id = "agentStatusWrapper";
  container.innerHTML = `
    <div id="agentStatusRow" class="status-row">
      ${coreAgents
        .map(
          (name) => `
        <div class="agent-tile agent-core" data-agent="${name}">
          <div class="agent-dot status-offline"></div>
          <span class="agent-label">${name}</span>
        </div>`
        )
        .join("")}
    </div>
    <div id="stabilityStatusRow" class="status-row">
      <span class="row-label">Stability</span>
      ${stabilityAgents
        .map(
          (name) => `
        <div class="agent-tile agent-stability" data-agent="${name}">
          <div class="agent-dot status-offline"></div>
          <span class="agent-label">${name}</span>
        </div>`
        )
        .join("")}
    </div>
  `;
  document.body.prepend(container);

  function updateAgentStatus(name, status) {
    const tiles = document.querySelectorAll(`.agent-tile[data-agent="${name}"]`);
    if (!tiles.length) return;
    tiles.forEach((tile) => {
      const dot = tile.querySelector(".agent-dot");
      if (!dot) return;
      dot.className = `agent-dot status-${status}`;
    });
  }

  let connected = false;

  // Prefer live SSE if available
  try {
    const evtSource = new EventSource("http://localhost:3101/events/agents");
    evtSource.onopen = () => {
      connected = true;
      console.log("<0001f7e2> Connected to live agent SSE");
    };
    evtSource.onmessage = (e) => {
      try {
        const data = JSON.parse(e.data);
        for (const [name, value] of Object.entries(data)) {
          if (!allAgents.includes(name)) continue;
          const isOnline =
            typeof value === "boolean"
              ? value
              : typeof value === "string"
              ? value === "online"
              : !!value?.online;
          updateAgentStatus(name, isOnline ? "online" : "offline");
        }
      } catch {
        console.warn("⚠️ Invalid /events/agents payload — ignoring.");
      }
    };
    evtSource.onerror = () => {
      console.warn("⚠️ SSE /events/agents unavailable — using polling fallback");
      connected = false;
    };
  } catch {
    console.warn("⚠️ SSE connection failed at construction — using polling fallback");
  }

  // Fallback polling at 1 Hz using /health
  setInterval(async () => {
    if (connected) return;
    try {
      const res = await fetch("/health");
      if (!res.ok) throw new Error("Health endpoint not OK");
      const data = await res.json();

      allAgents.forEach((name) => {
        const direct = data[name];
        const lower = data[name.toLowerCase()];
        const value = direct !== undefined ? direct : lower;
        const isOnline =
          typeof value === "boolean"
            ? value
            : typeof value === "string"
            ? value === "online"
            : !!value?.online;
        updateAgentStatus(name, isOnline ? "online" : "offline");
      });
    } catch {
      allAgents.forEach((name) => updateAgentStatus(name, "offline"));
    }
  }, 1000);
});
