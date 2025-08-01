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

  // Shades of gray/black for minimalist elegance
  const agentColor = "#222";   // almost black
  const timeColor = "#666";    // medium gray
  const eventColor = "#999";   // lighter gray

  container.innerHTML = `
    <div class="ticker-item">
      <span style="color:${agentColor};">${ev.agent.toUpperCase()}</span>
      <span style="color:${timeColor};">${time}</span>
      <span style="color:${eventColor};">[${ev.event}]</span>
    </div>
  `;
}

setInterval(fetchTickerEvents, POLL_INTERVAL_MS);
setInterval(showNextEvent, 4000);

fetchTickerEvents();
