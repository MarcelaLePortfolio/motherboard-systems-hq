console.log("📡 Initializing dashboard SSE listener...");

const evtSource = new EventSource("/events/agents");

evtSource.onopen = () => console.log("✅ SSE connection established");
evtSource.onerror = (err) => console.error("❌ SSE error:", err);

evtSource.addEventListener("ping", () => {
  console.debug("💓 ping");
});

evtSource.addEventListener("log", (e) => {
  const data = JSON.parse(e.data);
  const container = document.getElementById("logOutput") || document.body;
  const line = document.createElement("div");
  line.textContent = `[${data.time}] ${data.source}: ${data.message}`;
  container.appendChild(line);
  console.log("🪵 Log event:", data);
});

evtSource.addEventListener("agent", (e) => {
  const data = JSON.parse(e.data);
  console.log("🤖 Agent update:", data);
});
