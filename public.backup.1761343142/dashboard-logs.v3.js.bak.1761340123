document.addEventListener("DOMContentLoaded", async () => {
  console.log("✅ dashboard-logs.v3.js running");

  const container = document.getElementById("recentLogs");
  if (!container) {
    console.warn("⚠️ No #recentLogs found in DOM");
    return;
  }

  async function fetchLogs(endpoint) {
    try {
      const res = await fetch(endpoint);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      console.log(`📥 ${endpoint} →`, data);
      return (data.rows ?? data) || [];
    } catch (err) {
      console.error(`❌ Fetch failed for ${endpoint}:`, err);
      return [];
    }
  }

  let logs = await fetchLogs("/reflections/recent");
  if (logs.length === 0) {
    console.log("⚠️ No reflections found; loading tasks instead");
    logs = await fetchLogs("/tasks/recent");
  }

  container.innerHTML = "";
  if (logs.length === 0) {
    container.textContent = "No logs available.";
    return;
  }

  logs.forEach(log => {
    const div = document.createElement("div");
    div.className = "log-item";
    div.style.cssText =
      "margin-bottom:8px;padding:6px 8px;border-bottom:1px solid #222;font-family:monospace;";
    div.innerHTML = `
      <span style="color:#7fffd4;"><b>${log.type}</b></span> — ${log.result}<br>
      <span style="color:#888;">${log.actor} · ${new Date(log.created_at).toLocaleString()}</span>
    `;
    container.appendChild(div);
  });
});
