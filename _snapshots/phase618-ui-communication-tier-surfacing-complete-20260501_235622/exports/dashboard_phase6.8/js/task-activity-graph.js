// <0001faf5> Phase 6.5 — Task Activity Graph (Phase One)
import Chart from "chart.js/auto";

export function renderTaskActivityGraph(ctx, data) {
  const timestamps = data.map(d => d.created_at);
  const labels = timestamps.map(t => new Date(t).toLocaleTimeString());
  const counts = data.map((_d, i) => i + 1);

  return new Chart(ctx, {
    type: "line",
    data: {
      labels,
      datasets: [{
        label: "Task Activity",
        data: counts,
        borderWidth: 2,
        tension: 0.3,
      }]
    },
    options: {
      responsive: true,
      scales: { y: { beginAtZero: true } },
      plugins: {
        legend: { display: true },
      },
    },
  });
}
