// <0001fae9> Phase 9.6.4 — Reflection Timestamp & Content Fix
const reflectionsFeed = new EventSource("http://localhost:3101/events/reflections");
const container = document.getElementById("recentLogs");

function createEntry(data) {
  const wrapper = document.createElement("div");
  wrapper.className = "reflection-line";

  // Safely handle missing or malformed timestamps
  const rawTime = data.created_at ? new Date(data.created_at) : new Date();
  const time = isNaN(rawTime.getTime())
    ? new Date().toLocaleTimeString()
    : rawTime.toLocaleTimeString();

  // Handle cases where content may be missing or null
  const content = data.content || "(no content)";

  wrapper.textContent = `[${time}] ${content}`;
  wrapper.style.opacity = "0";
  container.prepend(wrapper);

  // Smooth fade-in animation
  requestAnimationFrame(() => {
    wrapper.style.transition = "opacity 0.6s ease-in-out";
    wrapper.style.opacity = "1";
  });

  // Keep max 20 visible lines
  if (container.children.length > 20) container.removeChild(container.lastChild);
}

reflectionsFeed.onopen = () => console.log("🪞 Reflections stream connected");

reflectionsFeed.onmessage = (e) => {
  try {
    const data = JSON.parse(e.data);
    if (container if (container) createEntry(data);if (container) createEntry(data); data.content) createEntry(data);
  } catch (err) {
    console.error("⚠️ Reflection parse error:", err);
  }
};

reflectionsFeed.onerror = (err) => {
  console.error("❌ Reflections SSE error:", err);
};
