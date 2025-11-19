// <0001faea> Phase 4.8.1 — Self-Healing Reflections Viewer (recreates panel if missing)
document.addEventListener("DOMContentLoaded", () => {
  console.log("📡 Reflections viewer initializing...");

  function ensurePanel() {
    let panel = document.getElementById("recentLogs");
    if (!panel) {
      console.warn("⚠️ No #recentLogs container found — injecting fallback section.");
      const container = document.querySelector("#recent-activity") || document.body;
      panel = document.createElement("div");
      panel.id = "recentLogs";
      panel.style = "padding:8px;font-family:monospace;color:#ccc;";
      container.appendChild(panel);
    }
    return panel;
  }

  function renderReflections(data) {
    const target = ensurePanel();
    if (!data || !Array.isArray(data)) return;
    target.innerHTML = data
      .map(
        (r) =>
          `<div style="color:#d8c088;margin-bottom:4px;">${escapeHtml(r.content)}<span style="float:right;color:#888;">${timeAgo(
            r.created_at
          )}</span></div>`
      )
      .join("");
  }

  function escapeHtml(str) {
    return str.replace(/[&<>"']/g, (ch) => {
      const map = { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#039;" };
      return map[ch];
    });
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
      console.warn("⚠️ SSE connection lost — reverting to polling fallback", err);
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
      ensurePanel().innerHTML = `<span style="color:red;">⚠️ Failed to load reflections</span>`;
      console.error("❌ Reflection viewer fallback error:", err);
    }
  }
});
