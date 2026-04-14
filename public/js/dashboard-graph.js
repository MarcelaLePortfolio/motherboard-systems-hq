(() => {
  const CANVAS_ID = "task-activity-graph";
  const TASKS_ENDPOINT = "/api/tasks";
  const REFRESH_MS = 3000;

  let chart = null;
  let refreshTimer = null;

  function getCanvas() {
    return document.getElementById(CANVAS_ID);
  }

  function ensureCanvasContext() {
    const canvas = getCanvas();
    if (!canvas) return null;
    return canvas.getContext("2d");
  }

  function safeArray(value) {
    return Array.isArray(value) ? value : [];
  }

  async function fetchTasks() {
    const res = await fetch(TASKS_ENDPOINT, {
      headers: { Accept: "application/json" },
      cache: "no-store",
    });

    if (!res.ok) {
      throw new Error(`Task Activity fetch failed: ${res.status} ${res.statusText}`);
    }

    const json = await res.json();
    return safeArray(json?.tasks);
  }

  function normalizeTask(task) {
    const updatedAt = task?.updated_at || task?.created_at || null;
    const status = String(task?.status || "unknown").toLowerCase();

    return {
      updatedAt,
      status,
    };
  }

  function buildBuckets(tasks) {
    const buckets = new Map();

    tasks
      .map(normalizeTask)
      .filter((task) => task.updatedAt)
      .forEach((task) => {
        const d = new Date(task.updatedAt);
        if (Number.isNaN(d.getTime())) return;

        d.setSeconds(0, 0);
        const key = d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });

        if (!buckets.has(key)) {
          buckets.set(key, {
            queued: 0,
            active: 0,
            completed: 0,
            failed: 0,
          });
        }

        const bucket = buckets.get(key);

        if (/fail|error|cancel|timeout/.test(task.status)) {
          bucket.failed += 1;
        } else if (/complete|done|success|ok/.test(task.status)) {
          bucket.completed += 1;
        } else if (/run|start|active|progress/.test(task.status)) {
          bucket.active += 1;
        } else {
          bucket.queued += 1;
        }
      });

    const labels = Array.from(buckets.keys());
    const queued = labels.map((label) => buckets.get(label).queued);
    const active = labels.map((label) => buckets.get(label).active);
    const completed = labels.map((label) => buckets.get(label).completed);
    const failed = labels.map((label) => buckets.get(label).failed);

    return { labels, queued, active, completed, failed };
  }

  function renderEmptyState(ctx) {
    if (chart) {
      chart.destroy();
      chart = null;
    }

    chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: ["No Data"],
        datasets: [
          {
            label: "Queued",
            data: [0],
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        animation: false,
        plugins: {
          legend: { display: true },
        },
        scales: {
          y: {
            beginAtZero: true,
          },
        },
      },
    });
  }

  function renderChart(ctx, series) {
    if (!series.labels.length) {
      renderEmptyState(ctx);
      return;
    }

    const data = {
      labels: series.labels,
      datasets: [
        {
          label: "Queued",
          data: series.queued,
        },
        {
          label: "Active",
          data: series.active,
        },
        {
          label: "Completed",
          data: series.completed,
        },
        {
          label: "Failed",
          data: series.failed,
        },
      ],
    };

    if (chart) {
      chart.data = data;
      chart.update();
      return;
    }

    chart = new Chart(ctx, {
      type: "line",
      data,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        animation: false,
        plugins: {
          legend: { display: true },
        },
        scales: {
          x: {
            title: {
              display: true,
              text: "Time",
            },
          },
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: "Task Count",
            },
          },
        },
      },
    });
  }

  async function refresh() {
    const ctx = ensureCanvasContext();
    if (!ctx || typeof Chart === "undefined") return;

    try {
      const tasks = await fetchTasks();
      const series = buildBuckets(tasks);
      renderChart(ctx, series);
    } catch (error) {
      console.error("[dashboard-graph]", error);
      renderEmptyState(ctx);
    }
  }

  function start() {
    refresh();
    refreshTimer = window.setInterval(refresh, REFRESH_MS);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }

  window.addEventListener("beforeunload", () => {
    if (refreshTimer) {
      clearInterval(refreshTimer);
      refreshTimer = null;
    }
  });
})();
