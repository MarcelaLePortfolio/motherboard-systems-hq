const POLL_INTERVAL_MS = 5000;
let lastIndex = 0;
let eventsBuffer = [];

async function fetchTickerEvents() {
  try {
    const res = await fetch("http://localhost:3081/ticker");
    const events = await res.json();
    console.log("📡 Ticker events:", events);

    // Update buffer
    eventsBuffer = events;
  } catch (err) {
    console.error("❌ Failed to fetch ticker events:", err);
  }
}

// Rotate one event at a time
function showNextEvent() {
  const container = document.getElementById("log");
  if (!container || eventsBuffer.length === 0) return;

  // Cycle through events
  const ev = eventsBuffer[lastIndex % eventsBuffer.length];
  lastIndex++;

  const time = new Date(ev.timestamp * 1000).toLocaleTimeString();
  const color = ev.agent === "cade" ? "#0af"
              : ev.agent === "effie" ? "#ff0"
              : "#0f0";

  container.innerHTML = `
    <div class="ticker-item">
      <span style="color:${color}; font-weight:bold;">${ev.agent.toUpperCase()}</span>
      <span style="color:#999;">${time}</span>
      <span style="color:#ffa500;">[${ev.event}]</span>
    </div>
  `;
}

// Poll logs and rotate every few seconds
setInterval(fetchTickerEvents, POLL_INTERVAL_MS);
setInterval(showNextEvent, 4000);

fetchTickerEvents();
