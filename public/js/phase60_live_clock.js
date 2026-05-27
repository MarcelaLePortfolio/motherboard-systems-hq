/*
Phase 60 — Live Clock + Uptime Tick
Pure UI enhancement — no architecture changes.
Makes the console feel active by updating uptime every second.
*/

function formatUptime(seconds) {
  const h = Math.floor(seconds / 3600).toString().padStart(2, '0');
  const m = Math.floor((seconds % 3600) / 60).toString().padStart(2, '0');
  const s = Math.floor(seconds % 60).toString().padStart(2, '0');
  return `${h}:${m}:${s}`;
}

(function startUptimeTicker() {
  const el = document.getElementById("uptime-display");
  if (!el) return;

  let start = Date.now();

  setInterval(() => {
    const elapsed = Math.floor((Date.now() - start) / 1000);
    el.textContent = formatUptime(elapsed);
  }, 1000);
})();
