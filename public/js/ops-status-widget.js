(function () {
  function createOpsStatusPill() {
    let pill = document.getElementById("ops-status-pill");
    if (pill) return pill;

    pill = document.createElement("div");
    pill.id = "ops-status-pill";
    pill.textContent = "OPS: initializing…";

    // Simple dark pill in bottom-right
    pill.style.position = "fixed";
    pill.style.bottom = "16px";
    pill.style.right = "16px";
    pill.style.zIndex = "9999";
    pill.style.padding = "8px 12px";
    pill.style.borderRadius = "999px";
    pill.style.fontFamily = "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif";
    pill.style.fontSize = "12px";
    pill.style.letterSpacing = "0.03em";
    pill.style.background = "rgba(10, 10, 10, 0.9)";
    pill.style.color = "#eee";
    pill.style.border = "1px solid rgba(255, 255, 255, 0.15)";
    pill.style.boxShadow = "0 0 8px rgba(0, 0, 0, 0.8)";

    document.body.appendChild(pill);
    return pill;
  }

  function formatTime(ts) {
    if (!ts) return "–";
    try {
      const d = new Date(ts);
      return d.toLocaleTimeString();
    } catch (_) {
      return "–";
    }
  }

  function updatePill() {
    const pill = createOpsStatusPill();

    const hb = window.lastOpsHeartbeat;
    const now = Date.now();

    let status = "DISCONNECTED";
    let color = "#999";
    let detail = "";

    if (hb && hb.ts) {
      const age = now - hb.ts;
      if (age < 15000) {
        status = "ONLINE";
        color = "#4ade80"; // green-ish
      } else {
        status = "STALE";
        color = "#fbbf24"; // amber
      }
      detail = ` • last: ${formatTime(hb.ts)}`;
    } else {
      status = "NO SIGNAL";
      color = "#f97373";
    }

    pill.textContent = `OPS: ${status}${detail}`;
    pill.style.borderColor = color;
    pill.style.boxShadow = `0 0 10px ${color}55`;
  }

  function startOpsStatusWatcher() {
    // Update immediately and then on a short interval
    updatePill();
    setInterval(updatePill, 5000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", startOpsStatusWatcher);
  } else {
    startOpsStatusWatcher();
  }
})();
