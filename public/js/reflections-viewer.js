// <0001fae0> Phase 4.8 — Dashboard SSE Listener Integration (live push + fallback)
document.addEventListener("DOMContentLoaded", () => {
  const target = document.getElementById("recentLogs");

  function renderReflections(reflections) {
    target.innerHTML = reflections
      .map(
        (r) =>
          `<div style="padding:2px 0;color:#caa;">
            <span style="color:#b78;">${timeAgo(r.created_at)}</span> — ${escapeHtml(r.content)}
          </div>`
      )
      .join("");
  }

  function timeAgo(ts) {
    const date = new Date(ts);
    const diff = Math.floor((Date.now() - date.getTime()) / 1000);
    const units = [
      ["year", 31536000],
      ["month", 2592000],
      ["day", 86400],
      ["hour", 3600],
      ["minute", 60],
    ];
    for (const [unit, sec] of units) {
      const interval = Math.floor(diff / sec);
      if (interval >= 1) return `${interval} ${unit}${interval > 1 ? "s" : ""} ago`;
    }
    return "Just now";
  }

  function escapeHtml(str) {
    return str.replace(/[&<>"']/g, (ch) => {
      const map = { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#039;" };
      return map[ch];
    });
  }

  // --- Phase 4.8: SSE integration with graceful fallback ---
  try {
    const evtSource = new EventSource("http://localhost:3101/events/reflections");
    console.log("📡 Connected to Reflection SSE stream...");
    evtSource.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        renderReflections(data);
      } catch (err) {
        console.error("❌ Failed to parse SSE data:", err);
      }
    };
    evtSource.onerror = (err) => {
      console.warn("⚠️ SSE connection lost — reverting to 20s polling fallback", err);
      evtSource.close();
      setInterval(loadReflectionsFallback, 20000);
    };
  } catch (err) {
    console.error("❌ SSE not supported, using fallback polling.", err);
    setInterval(loadReflectionsFallback, 20000);
  }

  async function loadReflectionsFallback() {
    try {
      const res = await fetch("/tmp/reflections.json");
      if (!res.ok) throw new Error(res.statusText);
      const data = await res.json();
      renderReflections(data);
    } catch (err) {
      target.innerHTML = `<span style="color:red;">⚠️ Failed to load reflections</span>`;
      console.error("❌ Reflection viewer fallback error:", err);
    }
  }
});
