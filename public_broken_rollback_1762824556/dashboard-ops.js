console.log("<0001fe20> dashboard-ops.js initialized");

document.addEventListener("DOMContentLoaded", () => {
  const evtSource = new EventSource("http://localhost:3201/events/ops");
  evtSource.onopen = () => console.log("<0001fe21> Connected to OPS SSE");
  evtSource.onerror = (err) => console.warn("⚠️ OPS SSE error", err);

  evtSource.onmessage = (e) => {
    try {
      const data = JSON.parse(e.data);
      console.log("<0001fe22> OPS update received:", data);
    } catch (err) {
      console.warn("⚠️ OPS parse error:", err);
    }
  };
});
