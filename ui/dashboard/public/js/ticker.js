const TICKER_ENDPOINT = "http://localhost:3080";
const TICKER_CONTAINER_ID = "ticker";
const POLL_INTERVAL_MS = 5000;

async function fetchTickerEvents() {
  try {
    const res = await fetch(TICKER_ENDPOINT);
    const events = await res.json();

    const container = document.getElementById(TICKER_CONTAINER_ID);
    if (!container) return;

    container.innerHTML = "";
    events.slice(-10).forEach(ev => {
      const item = document.createElement("div");
      item.className = "ticker-item";
      const date = new Date(ev.timestamp * 1000).toLocaleTimeString();
      item.textContent = `[${date}] ${ev.agent.toUpperCase()}: ${ev.event}`;
      container.appendChild(item);
    });
  } catch (err) {
    console.error("❌ Failed to fetch ticker events:", err);
  }
}

setInterval(fetchTickerEvents, POLL_INTERVAL_MS);
fetchTickerEvents();
