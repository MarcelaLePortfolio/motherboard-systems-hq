// <0001fbd4> Phase 9.19.5 — Anchor via "Dashboard v2.0.3" text node
document.addEventListener("DOMContentLoaded", () => {
  const agents = ["Matilda", "Cade", "Effie"];
  const stability = ["OPS", "Reflections"];

  // 🧭 Anchor: prefer stable id on the build/diagnostics banner
function __mbhqFindAnchor() {
  const byId = document.getElementById("dashboard-build-banner");
  if (byId) return byId;

  // fallback: first element that contains "Dashboard" and "Phase"
  const all = Array.from(document.querySelectorAll("body *"));
  const hit = all.find(el => {
    const t = (el && el.textContent) ? el.textContent : "";
    return t.includes("Dashboard") && t.includes("Phase");
  });
  if (hit) return hit;

  console.warn("⚠️ Could not find dashboard-build-banner anchor — appending to body instead");
  return document.body;
}
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
