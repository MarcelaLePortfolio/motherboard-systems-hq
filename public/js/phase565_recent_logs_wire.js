(function () {
  const buffer = [];

  function renderLogs(logs) {
    const mount = document.getElementById("recentLogs");
    if (!mount) return;

    mount.setAttribute("data-phase565-recent-logs-wire", "active");
    mount.innerHTML = "";

    if (!Array.isArray(logs) || logs.length === 0) {
      mount.textContent = "No recent logs.";
      return;
    }

    const list = document.createElement("div");
    list.style.display = "grid";
    list.style.gap = "0.5rem";

    logs.slice(-20).reverse().forEach(function (log) {
      const line = document.createElement("div");
      line.className = "text-xs text-gray-400";

      const ts = log.timestamp ? new Date(log.timestamp).toLocaleTimeString() : "";
      const msg = typeof log === "string" ? log : (log.message || JSON.stringify(log));

      line.textContent = (ts ? "[" + ts + "] " : "") + msg;
      list.appendChild(line);
    });

    mount.appendChild(list);
  }

  function connectSSE() {
    renderLogs(buffer);

    try {
      const evt = new EventSource("/events/tasks");

      evt.onmessage = function (e) {
        try {
          const data = JSON.parse(e.data);
          buffer.push({
            timestamp: Date.now(),
            message: JSON.stringify(data)
          });
          renderLogs(buffer);
        } catch (_) {}
      };

      evt.onerror = function () {};
    } catch (_) {
      renderLogs(buffer);
    }
  }

  function startRecentLogsWire() {
    connectSSE();

    let runs = 0;
    const timer = window.setInterval(function () {
      runs += 1;
      renderLogs(buffer);

      if (runs >= 10) {
        window.clearInterval(timer);
      }
    }, 500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", startRecentLogsWire, { once: true });
  } else {
    startRecentLogsWire();
  }
})();
