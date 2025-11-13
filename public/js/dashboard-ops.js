// Clean Reset — OPS SSE handler

const opsEl = document.getElementById("recentTasks");
const opsStream = new EventSource("http://localhost:3201/events/ops");

opsStream.onopen = () => console.log("🟢 OPS SSE connected");
opsStream.onerror = (e) => console.error("❌ OPS SSE error:", e);

opsStream.onmessage = (e) => {
  try {
    const data = JSON.parse(e.data);

    const line = document.createElement("div");
    line.className = "task-line";
    line.textContent = `[${data.timestamp}] ${data.status || data.message}`;
    opsEl.prepend(line);

    while (opsEl.children.length > 50)
      opsEl.removeChild(opsEl.lastChild);

  } catch (err) {
    console.error("OPS parsing error:", err);
  }
};
