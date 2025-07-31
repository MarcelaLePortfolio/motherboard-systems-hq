const STATUS_POLL_MS = 5000;
const STATUS_URL = "http://localhost:3081";

async function fetchAgentStatus() {
  try {
    const res = await fetch(STATUS_URL);
    const status = await res.json();

    // Update UI for each agent if matching elements exist
    ['cade', 'effie', 'matilda'].forEach(agent => {
      const el = document.getElementById(agent + '-status');
      if (el) {
        el.textContent = status[agent].toUpperCase();
        el.style.color = (status[agent] === 'online') ? '#0f0' : '#f00';
      }
    });

  } catch (err) {
    console.error("❌ Failed to fetch agent status:", err);
  }
}

setInterval(fetchAgentStatus, STATUS_POLL_MS);
fetchAgentStatus();
