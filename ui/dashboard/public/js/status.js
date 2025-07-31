const STATUS_POLL_MS = 5000;
const STATUS_URL = "http://localhost:3081"; // Explicit live API

async function fetchAgentStatus() {
  try {
    const res = await fetch(STATUS_URL);
    const status = await res.json();
    console.log("📡 Agent status:", status);

    ['matilda', 'cade', 'effie'].forEach(agent => {
      const el = document.getElementById(agent + '-indicator');
      if (!el) return;
      el.style.backgroundColor = status[agent] === 'online' ? 'green'
                                 : status[agent] === 'offline' ? 'red'
                                 : 'gray';
    });

  } catch (err) {
    console.error("❌ Failed to fetch agent status:", err);
  }
}

setInterval(fetchAgentStatus, STATUS_POLL_MS);
fetchAgentStatus();
