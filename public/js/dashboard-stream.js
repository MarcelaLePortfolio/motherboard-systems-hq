// <0001fae3> Phase 9.6.1 — Reflections SSE Wiring
const reflectionsFeed = new EventSource("http://localhost:3101/events/reflections");

reflectionsFeed.onopen = () => {
  console.log("🪞 Reflections stream connected");
};

reflectionsFeed.onmessage = (e) => {
  try {
    const data = JSON.parse(e.data);
    const container = document.getElementById("recentLogs");
    if (container) {
      const entry = document.createElement("div");
      entry.textContent = `[${new Date(data.created_at).toLocaleTimeString()}] ${data.content}`;
      container.prepend(entry);
      // Maintain max 20 lines for cinematic pacing
      while (container.children.length > 20) container.removeChild(container.lastChild);
    }
  } catch (err) {
    console.error("⚠️ Reflection parse error:", err);
  }
};

reflectionsFeed.onerror = (err) => {
  console.error("❌ Reflections SSE error:", err);
};
