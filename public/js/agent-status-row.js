// <0001fafa> Phase 9.2 — Agent Status Row Reintegration
// Displays live agent heartbeats beneath the system banner

const statusRow = document.createElement("div");
statusRow.id = "agent-status-row";
statusRow.style.display = "flex";
statusRow.style.justifyContent = "center";
statusRow.style.gap = "24px";
statusRow.style.padding = "8px 0";
statusRow.style.fontFamily = "var(--font-family, 'IBM Plex Sans')";
statusRow.style.background = "rgba(0,0,0,0.4)";
statusRow.style.color = "#fff";
statusRow.style.fontSize = "14px";
document.body.prepend(statusRow);

const agents = ["Matilda", "Cade", "Effie", "Atlas"];
const indicators = {};

agents.forEach((agent) => {
  const span = document.createElement("span");
  span.innerText = `${agent}: ⏳`;
  indicators[agent] = span;
  statusRow.appendChild(span);
});

const evtSource = new EventSource("http://localhost:3201/events/ops");
evtSource.onmessage = (e) => {
  try {
    const data = JSON.parse(e.data);
    if (data.agent && indicators[data.agent]) {
      const status = data.status || "unknown";
      indicators[data.agent].innerText = `${data.agent}: ${status}`;
      if (status.toLowerCase().includes("online") || status.toLowerCase().includes("ready")) {
        indicators[data.agent].style.color = "#80ffb0";
      } else if (status.toLowerCase().includes("error") || status.toLowerCase().includes("failed")) {
        indicators[data.agent].style.color = "#ff7070";
      } else {
        indicators[data.agent].style.color = "#ffd580";
      }
    }
  } catch (err) {
    console.warn("⚠️ Agent status parse error:", e.data);
  }
};
