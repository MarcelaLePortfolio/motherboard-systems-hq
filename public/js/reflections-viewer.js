// <0001facb> Phase 4.5 — Safe Incremental Reflections Panel Injection
document.addEventListener("DOMContentLoaded", () => {
  const target = document.querySelector("#reflections-panel");
  if (!target) {
    console.warn("⚠️ Reflections panel not found — skipping viewer injection.");
    return;
  }

  async function renderReflections() {
    try {
      const res = await fetch("/tmp/reflections.json", { cache: "no-store" });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();

      if (!Array.isArray(data) || !data.length) {
        target.innerHTML = "<em>No reflections recorded yet.</em>";
        return;
      }

      target.innerHTML = data
        .map(
          (r) => `
          <div class="reflection-item">
            <div class="reflection-meta">
              <span class="id">#${r.id}</span>
              <span class="time">${timeAgo(r.created_at)}</span>
            </div>
            <div class="reflection-text">${escapeHtml(r.content)}</div>
          </div>`
        )
        .join("");
    } catch (err) {
      console.error("Reflections viewer error:", err);
      target.innerHTML = `<span class="error">⚠️ Failed to load reflections</span>`;
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
    for (const [unit, seconds] of units) {
      const interval = Math.floor(diff / seconds);
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
