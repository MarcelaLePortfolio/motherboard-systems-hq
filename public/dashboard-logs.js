document.addEventListener("DOMContentLoaded", () => {
  console.log("📜 dashboard-logs.js (placeholder) active");

  const container = document.getElementById("recentLogs");
  if (!container) {
    console.warn("⚠️ No #recentLogs found in DOM");
    return;
  }

  container.innerHTML = `
    <div style="color:#888; font-style:italic; padding:6px;">
      Reflection logs will appear here once the pipeline is connected.
    </div>
  `;
});
