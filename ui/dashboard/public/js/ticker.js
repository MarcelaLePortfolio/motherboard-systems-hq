const POLL_INTERVAL_MS = 5000;
let lastIndex = 0;
let eventsBuffer = [];

async function fetchTickerEvents() {
  try {
    const res = await fetch("http://localhost:3081/ticker");
    const events = await res.json();
    console.log("📡 Ticker events:", events);

    eventsBuffer = events;
  } catch (err) {
    console.error("❌ Failed to fetch ticker events:", err);
  }
}

function showNextEvent() {
  const container = document.getElementById("log");
  if (!container || eventsBuffer.length === 0) return;

  const ev = eventsBuffer[lastIndex % eventsBuffer.length];
  lastIndex++;

  const time = new Date(ev.timestamp * 1000).toLocaleTimeString();

  // Bolder colors
  const color = ev.agent === "cade" ? "#00c8ff"  // brighter blue
              : ev.agent === "effie" ? "#ffd700" // bold gold
              : "#00ff00";                       // vivid green

  container.innerHTML = `
    <div class="ticker-item">
      <span style="color:${color}; font-weight:bold;">${ev.agent.toUpperCase()}</span>
      <span style="color:#fff;">${time}</span>
      <span style="color:#ff6600;">[${ev.event}]</span>
    </div>
  `;
}

setInterval(fetchTickerEvents, POLL_INTERVAL_MS);
setInterval(showNextEvent, 4000);

fetchTickerEvents();
