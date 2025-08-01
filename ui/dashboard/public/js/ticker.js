const POLL_INTERVAL_MS = 5000;
let lastTimestamp = 0;  // Track the newest event we've shown

async function fetchTickerEvents() {
  try {
    const res = await fetch("http://localhost:3081/ticker");
    const events = await res.json();
    console.log("📡 Ticker events:", events);

    const container = document.getElementById("log");
    if (!container) return;

    // Filter only new events based on timestamp
    const newEvents = events.filter(ev => ev.timestamp > lastTimestamp);
    if (newEvents.length === 0) return;

    newEvents.forEach(ev => {
      const row = document.createElement("div");
      row.className = "ticker-item"; // Only new items animate

      const time = new Date(ev.timestamp * 1000).toLocaleTimeString();
      const color = ev.agent === "cade" ? "#0af"
                  : ev.agent === "effie" ? "#ff0"
                  : "#0f0";

      row.innerHTML = `
        <span style="color:${color}; font-weight:bold; width:7rem; display:inline-block;">
          ${ev.agent.toUpperCase()}
        </span>
        <span style="color:#999; width:5rem; display:inline-block;">${time}</span>
        <span style="color:#ffa500;">[${ev.event}]</span>
      `;

      container.appendChild(row);
      container.scrollTop = container.scrollHeight;

      // Update lastTimestamp to the newest event we just appended
      lastTimestamp = Math.max(lastTimestamp, ev.timestamp);
    });
  } catch (err) {
    console.error("❌ Failed to fetch ticker events:", err);
  }
}

setInterval(fetchTickerEvents, POLL_INTERVAL_MS);
fetchTickerEvents();
