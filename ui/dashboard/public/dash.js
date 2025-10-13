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
