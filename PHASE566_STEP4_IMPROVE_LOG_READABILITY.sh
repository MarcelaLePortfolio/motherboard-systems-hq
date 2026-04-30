#!/bin/bash
set -e

echo "Improving Recent Logs readability..."

cat > public/js/phase565_recent_logs_wire.js << 'JS'
(function () {
  const buffer = [];

  function summarizeEvent(data) {
    if (!data || typeof data !== "object") return String(data || "event received");

    const type = data.type || data.event || data.status || "task event";
    const id = data.task_id || data.taskId || data.id || "";
    const status = data.status ? " · " + data.status : "";

    return String(type) + (id ? " · " + id : "") + status;
  }

  function renderLogs(logs) {
    const mount = document.getElementById("recentLogs");
    if (!mount) return;

    mount.innerHTML = "";

    if (!Array.isArray(logs) || logs.length === 0) {
      mount.textContent = "No task history yet.";
      return;
    }

    const list = document.createElement("div");
    list.style.display = "grid";
    list.style.gap = "0.5rem";

    logs.slice(-20).reverse().forEach(function (log) {
      const line = document.createElement("div");
      line.className = "text-xs text-gray-400 leading-5";

      const ts = log.timestamp ? new Date(log.timestamp).toLocaleTimeString() : "";
      line.textContent = (ts ? "[" + ts + "] " : "") + log.message;

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
            message: summarizeEvent(data)
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
JS

node --check public/js/phase565_recent_logs_wire.js
docker compose up -d --build dashboard

git add public/js/phase565_recent_logs_wire.js
git commit -m "Phase 566: improve Recent Logs event readability"
git push
