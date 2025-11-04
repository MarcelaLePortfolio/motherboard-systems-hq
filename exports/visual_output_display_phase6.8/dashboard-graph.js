// <0001fae8> Phase 6.3 — Task Activity Graph (Phase One)
import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

const ctx = document.getElementById("taskActivityGraph").getContext("2d");
let chart;

async function fetchOPSData() {
  const res = await fetch("/tmp/ops.json").catch(() => null);
  if (!res || !res.ok) return [];
  return await res.json();
}

async function renderGraph() {
  const data = await fetchOPSData();
  const labels = data.map((d) => new Date(d.created_at).toLocaleTimeString());
  const counts = data.map((_, i) => i + 1);

  if (chart) chart.destroy();
  chart = new Chart(ctx, {
    type: "line",
    data: {
      labels,
      datasets: [
        {
          label: "Task Activity",
          data: counts,
          borderWidth: 2,
          fill: false,
        },
      ],
    },
    options: {
      responsive: true,
      plugins: {
        legend: { display: true },
      },
      scales: {
        x: { title: { display: true, text: "Time" } },
        y: { title: { display: true, text: "Task Count" }, beginAtZero: true },
      },
    },
  });
}

setInterval(renderGraph, 3000);
renderGraph();
