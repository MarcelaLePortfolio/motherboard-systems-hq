const POLL_INTERVAL_MS = 5000;
const TICKER_URL = "http://localhost:3081/ticker";

async function fetchTickerEvents() {
  try {
    const res = await fetch(TICKER_URL);
    const events = await res.json();
    console.log("📡 Ticker events:", events);

    const container = document.getElementById("log");
    if (!container) return;

    container.innerHTML = "";
    events.slice(-10).forEach(ev => {
      const row = document.createElement("div");
      row.className = "ticker-item";

      const time = new Date(ev.timestamp * 1000).toLocaleTimeString();
      const color = ev.agent === "cade" ? "#0af"
                  : ev.agent === "effie" ? "#ff0"
                  : "#0f0";
      const icon = ev.agent === "cade" ? "🛠"
                 : ev.agent === "effie" ? "🖥"
                 : "🧠";

      row.innerHTML = `
        <span style="color:${color}; font-weight:bold; width:7rem; display:inline-block;">
          ${icon} ${ev.agent.toUpperCase()}
        </span>
        <span style="color:#999; width:5rem; display:inline-block;">${time}</span>
        <span style="color:#333;">[${ev.event}]</span>
      `;
      container.appendChild(row);
    });
  } catch (err) {
    console.error("❌ Failed to fetch ticker events:", err);
  }
}

setInterval(fetchTickerEvents, POLL_INTERVAL_MS);
fetchTickerEvents();
