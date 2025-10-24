document.addEventListener("DOMContentLoaded", async () => {
  console.log("📋 DOM fully loaded — dashboard.js executing safely");

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
          <span style="color:#999;">${row.actor} · ${new Date(row.created_at).toLocaleString()}</span>
        </div>
      `)
      .join("");
  } catch (err) {
    console.error("❌ Failed to load recent tasks:", err);
    container.innerText = "Error loading tasks.";
  }
});
