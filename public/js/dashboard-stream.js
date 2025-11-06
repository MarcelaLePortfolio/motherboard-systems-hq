// <0001fae7> Phase 9.6.3 — Cinematic Reflection Styling & Pacing
const reflectionsFeed = new EventSource("http://localhost:3101/events/reflections");
const container = document.getElementById("recentLogs");

function createEntry(data) {
  const wrapper = document.createElement("div");
  wrapper.className = "reflection-line";
  const time = new Date(data.created_at).toLocaleTimeString();
  wrapper.textContent = `[${time}] ${data.content}`;
  wrapper.style.opacity = "0";
  container.prepend(wrapper);

  // Fade-in animation
  requestAnimationFrame(() => {
    wrapper.style.transition = "opacity 0.6s ease-in-out";
    wrapper.style.opacity = "1";
  });

  // Keep a clean cinematic rhythm — 1 Hz pacing
  setTimeout(() => {
    if (container.children.length > 20) container.removeChild(container.lastChild);
  }, 1000);
}

reflectionsFeed.onopen = () => console.log("🪞 Reflections stream connected");

reflectionsFeed.onmessage = (e) => {
  try {
    const data = JSON.parse(e.data);
    if (container) createEntry(data);
  } catch (err) {
    console.error("⚠️ Reflection parse error:", err);
  }
};

reflectionsFeed.onerror = (err) => {
  console.error("❌ Reflections SSE error:", err);
};
