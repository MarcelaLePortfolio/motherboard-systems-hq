/* eslint-disable import/no-commonjs */
// ✅ Dashboard Script - Relative Fetch + Secure Agent Status

console.log("✅ Dashboard JS executing");

async function fetchAgentStatus() {
  try {
    const res = await fetch('./agent-status.json'); // ← now relative
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    console.log("📡 Fetched agent status:", data);
    // update DOM logic...
  } catch (err) {
    console.error("❌ Failed to fetch agent status:", err);
  }
}

// Poll every 5 seconds
fetchAgentStatus();
setInterval(fetchAgentStatus, 5000);
document.addEventListener("DOMContentLoaded", () => {
  const input = document.getElementById("chat-input");
  const sendBtn = document.getElementById("send-button");

  if (input && sendBtn) {
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        sendBtn.click();
      }
    });
  }
});
