const POLL_INTERVAL_MS = 5000;
let lastTimestamp = 0;

async function fetchTickerEvents() {
  try {
    const res = await fetch("http://localhost:3081/ticker");
    const events = await res.json();
    console.log("📡 Ticker events:", events);

    const container = document.getElementById("log");
    if (!container) return;

    const newEvents = events.filter(ev => ev.timestamp > lastTimestamp);
    if (newEvents.length === 0) return;

    newEvents.forEach(ev => {
      const row = document.createElement("div");
      row.className = "ticker-item";

      const agent = document.createElement("span");
      agent.className = "agent";
      agent.style.color = ev.agent === "cade" ? "#0af"
                       : ev.agent === "effie" ? "#ff0"
                       : "#0f0";
      agent.textContent = ev.agent.toUpperCase();

      const time = document.createElement("span");
      time.className = "time";
      time.textContent = new Date(ev.timestamp * 1000).toLocaleTimeString();

      const event = document.createElement("span");
      event.className = "event";
      event.textContent = `[${ev.event}]`;

      row.appendChild(agent);
      row.appendChild(time);
      row.appendChild(event);

      container.appendChild(row);
      container.scrollTop = container.scrollHeight;
      lastTimestamp = Math.max(lastTimestamp, ev.timestamp);
    });
  } catch (err) {
    console.error("❌ Failed to fetch ticker events:", err);
  }
}

setInterval(fetchTickerEvents, POLL_INTERVAL_MS);
fetchTickerEvents();
