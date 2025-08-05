const STATUS_POLL_MS = 5000;
const STATUS_URL = "http://localhost:3081";

async function fetchAgentStatus() {
  try {
    const res = await fetch(STATUS_URL);
    const status = await res.json();

    ['matilda', 'cade', 'effie'].forEach(agent => {
      const el = document.getElementById(agent + '-indicator');
      if (el) {
        el.style.backgroundColor = status[agent] === 'online' ? 'green' : 'red';
      }
    });
    console.log("📡 Agent status:", status);
  } catch (err) {
    console.error("❌ Error fetching agent status:", err);
  }
}

setInterval(fetchAgentStatus, STATUS_POLL_MS);
fetchAgentStatus();
