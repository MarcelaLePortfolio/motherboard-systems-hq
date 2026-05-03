// <0001fbd4> Phase 9.19.5 — Anchor via "Dashboard v2.0.3" text node
document.addEventListener("DOMContentLoaded", () => {
  const agents = ["Matilda", "Cade", "Effie"];
  const stability = ["OPS", "Reflections"];

  // 🧭 Find the blue diagnostics line that contains "Dashboard v2.0.3"
  const allElements = document.querySelectorAll("body *");
  let dashboardLine = null;
  for (const el of allElements) {
    if (el.textContent.includes("Dashboard v2.0.3")) {
      dashboardLine = el;
      break;
    }
  }

  // Build both rows
  const stabilityRow = document.createElement("div");
  stabilityRow.id = "stabilityStatusRow";
  stabilityRow.className = "status-row agent-stability";
  stabilityRow.innerHTML = `
    <span class="row-label">STABILITY</span>
    ${stability.map(name => `
      <div class="agent-tile" data-agent="${name}">
        <span class="agent-dot status-offline"></span>
        <span class="agent-label">${name}</span>
      </div>
    `).join("")}
  `;

  const agentRow = document.createElement("div");
  agentRow.id = "agentStatusRow";
  agentRow.className = "status-row agent-core";
  agentRow.innerHTML = agents.map(name => `
    <div class="agent-tile" data-agent="${name}">
      <span class="agent-dot status-offline"></span>
      <span class="agent-label">${name}</span>
    </div>
  `).join("");

  // Place rows above and below the blue diagnostics bar
  if (dashboardLine && dashboardLine.parentNode) {
    dashboardLine.parentNode.insertBefore(stabilityRow, dashboardLine);
    dashboardLine.parentNode.insertBefore(agentRow, dashboardLine.nextSibling);
  } else {
    console.warn("⚠️ Could not find Dashboard v2.0.3 anchor — appending to body instead");
    document.body.prepend(stabilityRow);
    document.body.appendChild(agentRow);
  }

  // Function to update dot states
  function updateAgentStatus(name, status) {
    const dot = document.querySelector(`.agent-tile[data-agent="${name}"] .agent-dot`);
    if (dot) dot.className = `agent-dot status-${status}`;
  }

  // Live SSE connection (if available)
  let connected = false;
  try {
    const evtSource = new EventSource("http://localhost:3101/events/agents");
    evtSource.onmessage = (e) => {
      connected = true;
      try {
        const data = JSON.parse(e.data);
        for (const [name, val] of Object.entries(data)) {
          const on = typeof val === "boolean" ? val : val === "online" || !!val?.online;
          updateAgentStatus(name, on ? "online" : "offline");
        }
      } catch {}
    };
    evtSource.onerror = () => { connected = false; };
  } catch { connected = false; }

  // Fallback polling every second
  setInterval(async () => {
    if (connected) return;
    try {
      const res = await fetch("/health");
      const data = await res.json();
      [...agents, ...stability].forEach(name => {
        const val = data[name] ?? data[name.toLowerCase()];
        const on = typeof val === "boolean" ? val : val === "online" || !!val?.online;
        updateAgentStatus(name, on ? "online" : "offline");
      });
    } catch {
      [...agents, ...stability].forEach(name => updateAgentStatus(name, "offline"));
    }
  }, 1000);
});
