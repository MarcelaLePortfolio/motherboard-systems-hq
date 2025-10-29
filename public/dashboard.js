document.addEventListener("DOMContentLoaded", async () => {
  console.log("📋 DOM fully loaded — dashboard.js executing safely");

  // Helper: Friendly time difference formatter
  function timeAgo(timestamp) {
    const now = new Date();
    const then = new Date(timestamp);
    const diff = (now - then) / 1000; // seconds
    if (isNaN(diff) || diff < 0) return "just now";

    const mins = Math.floor(diff / 60);
    const hrs = Math.floor(mins / 60);
    const days = Math.floor(hrs / 24);

    if (mins < 1) return "just now";
    if (mins < 60) return `${mins} min${mins === 1 ? "" : "s"} ago`;
    if (hrs < 24) return `${hrs} hr${hrs === 1 ? "" : "s"} ago`;
    return `${days} day${days === 1 ? "" : "s"} ago`;
  }

  const container = document.getElementById("recentTasks");
  if (!container) return console.warn("⚠️ No #recentTasks container found.");

  try {
    const res = await fetch("/tasks/recent");
    const data = await res.json();

    if (!data.rows || !Array.isArray(data.rows)) {
      container.innerText = "⚠️ No recent tasks available.";
      return;
    }

    container.innerHTML = data.rows
      .map(row => `
        <div style="padding:6px 0;border-bottom:1px solid #222;">
          <b style="color:#00ff7f;">${row.type}</b> — ${row.result || "(no result)"}<br>
          <span style="color:#999;">${row.actor} · ${timeAgo(row.created_at)}</span>
        </div>
      `)
      .join("");
  } catch (err) {
    console.error("❌ Failed to load recent tasks:", err);
    container.innerText = "Error loading tasks.";
  }
});
