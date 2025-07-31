const POLL_INTERVAL_MS = 5000;
const TICKER_URL = "/ticker-events.log"; // served statically or adjust if proxied

async function fetchTickerEvents() {
  try {
    const res = await fetch(TICKER_URL);
    const text = await res.text();
    const lines = text.trim().split("\n").filter(Boolean);
    const events = lines.map(line => {
      try { return JSON.parse(line); } catch { return null; }
    }).filter(Boolean);

    const container = document.getElementById("ticker");
    if (!container) return;

    container.innerHTML = "";

    events.slice(-10).forEach(ev => {
      const row = document.createElement("div");
      row.className = "ticker-item";

      const time = new Date(ev.timestamp * 1000)
        .toLocaleTimeString([], {hour:'2-digit', minute:'2-digit', second:'2-digit'});
      const agent = ev.agent?.toLowerCase() || "unknown";
      const event = ev.event || "unknown";

      let icon = "❔";
      let color = "gray";
      if (agent.includes("matilda")) { icon = "🧠"; color = "#a855f7"; }
      if (agent.includes("cade"))    { icon = "🛠️"; color = "#22c55e"; }
      if (agent.includes("effie"))   { icon = "🖥"; color = "#3b82f6"; }

      row.innerHTML = `
        <span style="color:${color}; font-weight:bold; width:7rem; display:inline-block;">
          ${icon} ${agent.toUpperCase()}
        </span>
        <span style="color:#999; width:5rem; display:inline-block;">${time}</span>
        <span style="color:#333;">[${event}]</span>
      `;
      container.appendChild(row);
    });
  } catch (err) {
    console.error("❌ Failed to fetch ticker events:", err);
  }
}

setInterval(fetchTickerEvents, POLL_INTERVAL_MS);
fetchTickerEvents();
