// <0001facd> Phase 4.5 — Reflections Integrated into Recent Logs Panel
document.addEventListener("DOMContentLoaded", () => {
  const logsPanel = document.querySelector("#recentLogs");
  if (!logsPanel) {
    console.warn("⚠️ #recentLogs not found — skipping reflections injection.");
    return;
  }

  async function renderReflections() {
    try {
      const res = await fetch("/tmp/reflections.json", { cache: "no-store" });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();

      if (!Array.isArray(data) || !data.length) return;

      const reflectionsHtml = data
        .map(
          (r) => `
          <div class="reflection-line" style="color:#b87333;">
            [${timeAgo(r.created_at)}] ${escapeHtml(r.content)}
          </div>`
        )
        .join("");

      // Insert below any existing log lines
      const marker = document.querySelector(".reflection-marker");
      if (marker) marker.remove(); // cleanup if already added
      logsPanel.insertAdjacentHTML("beforeend", `<div class="reflection-marker">${reflectionsHtml}</div>`);
    } catch (err) {
      console.error("❌ Reflections viewer error:", err);
    }
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

  renderReflections();
  setInterval(renderReflections, 20000);
});
