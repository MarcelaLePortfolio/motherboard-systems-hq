// Clean Reset — reflections SSE handler

const reflectionsEl = document.getElementById("recentLogs");
const reflectionsStream = new EventSource("http://localhost:3101/events/reflections");

reflectionsStream.onopen = () => console.log("🪞 Reflections SSE connected");
reflectionsStream.onerror = (e) => console.error("❌ Reflections SSE error:", e);

reflectionsStream.onmessage = (e) => {
  try {
    const data = JSON.parse(e.data);
    const div = document.createElement("div");
    div.className = "reflection-line";
    div.textContent = `[${data.timestamp}] ${data.message || data.content || ""}`;
    reflectionsEl.prepend(div);

    while (reflectionsEl.children.length > 50)
      reflectionsEl.removeChild(reflectionsEl.lastChild);

  } catch (err) {
    console.error("Reflection parsing error:", err);
  }
};
