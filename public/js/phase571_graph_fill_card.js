(function () {
  async function fetchTasks() {
    try {
      const res = await fetch("/api/tasks");
      const json = await res.json();
      return json.tasks || [];
    } catch (e) {
      console.error("[telemetry] fetch failed", e);
      return [];
    }
  }

  function renderMetrics(tasks) {
    const card = document.getElementById("task-activity-card");
    if (!card) return;

    const queued = tasks.filter(t => t.status === "queued").length;
    const running = tasks.filter(t => t.status === "running").length;
    const completed = tasks.filter(t => t.status === "completed").length;
    const failed = tasks.filter(t => t.status === "failed").length;

    const lastUpdated = tasks[0]?.updated_at || "—";

    card.innerHTML =
      '<div style="display:flex;flex-direction:column;gap:12px;height:100%;">' +
      '<div style="font-size:14px;opacity:0.7;">Telemetry Overview</div>' +
      '<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">' +
      '<div>Queued: <b>' + queued + '</b></div>' +
      '<div>Running: <b>' + running + '</b></div>' +
      '<div>Completed: <b>' + completed + '</b></div>' +
      '<div>Failed: <b>' + failed + '</b></div>' +
      '</div>' +
      '<div style="margin-top:auto;font-size:12px;opacity:0.6;">' +
      'Last update: ' + lastUpdated +
      '</div>' +
      '</div>';
  }

  async function tick() {
    const tasks = await fetchTasks();
    renderMetrics(tasks);
  }

  function start() {
    tick();
    setInterval(tick, 3000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }
})();
