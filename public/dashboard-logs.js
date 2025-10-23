document.body.insertAdjacentHTML("beforeend", "<div style="position:fixed;bottom:10px;right:10px;background:#333;color:#0f0;padding:4px 8px;border-radius:4px;font-family:monospace;">✅ logs.js loaded</div>");
console.log("📋 DOM fully loaded — dashboard-logs.js executing safely");

document.addEventListener("DOMContentLoaded", async () => {
  console.log("📋 DOM fully loaded — dashboard-logs.js executing safely");

  const container = document.getElementById("recentLogs");
  if (!container) {
    console.warn("⚠️ No #recentLogs container found.");
    return;
  }

  try {
    const res = await fetch("/reflections/recent");
    const logs = await res.json();

    container.innerHTML = "";
    logs.forEach(log => {
      const div = document.createElement("div");
      div.className = "log-item";
      div.style.marginBottom = "8px";
      div.style.padding = "6px 8px";
      div.style.borderBottom = "1px solid #222";
      div.style.fontFamily = "monospace";
      div.innerHTML = `
        <span style="color:#7fffd4;"><b>${log.type}</b></span>
        — ${log.result}<br>
        <span style="color:#888;">${log.actor} · ${new Date(log.created_at).toLocaleString()}</span>
      `;
      container.appendChild(div);
    });
  } catch (err) {
    console.error("❌ Failed to load logs:", err);
    container.textContent = "⚠️ Could not load logs.";
  }
});
