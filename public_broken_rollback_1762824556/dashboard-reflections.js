console.log("<0001fe10> dashboard-reflections.js initialized");

document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("recentLogs");
  if (!container) return;

  const evtSource = new EventSource("http://localhost:3101/events/reflections");
  evtSource.onopen = () => console.log("<0001fe11> Connected to Reflections SSE");
  evtSource.onerror = (err) => console.warn("⚠️ Reflections SSE error", err);

  evtSource.onmessage = (e) => {
    const div = document.createElement("div");
    div.className = "chat-message reflection";
    div.textContent = e.data;
    container.appendChild(div);
    container.scrollTop = container.scrollHeight;
  };
});
