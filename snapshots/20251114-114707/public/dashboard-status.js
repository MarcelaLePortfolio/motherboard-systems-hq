// --- Live Agent Status Stream ---
document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("agentStatusContainer");
  if (!container) {
    console.warn("⚠️ No #agentStatusContainer found in DOM");
    return;
  }

  const evtSource = new EventSource("http://localhost:3201/events/ops");

  evtSource.addEventListener("agent", (e) => {
    const { agents } = JSON.parse(e.data);
    container.innerHTML = agents
      .map(a => `<div style="padding:2px 0;color:${a.status === "online" ? "#6f6" : "#f66"};">
        <strong>${a.name}</strong> — ${a.status}
      </div>`)
      .join("");
  });

  evtSource.addEventListener("ping", () => {
    console.debug("💓 SSE ping received");
  });

  evtSource.onerror = (err) => {
    console.error("❌ SSE connection error:", err);
  };
});
