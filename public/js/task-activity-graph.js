// <0001fc22> Phase 2.2 — Exported Task Activity Graph Renderer

import { Chart } from "chart.js";

let activityChart;

/**
 * Exported so dashboard-graph-loader.js can import it.
 */
export function renderTaskActivityGraph(ctx, tasks) {
    // Extract labels and datasets
    const labels = tasks.map(t => new Date(t.timestamp * 1000).toLocaleTimeString());
    const completedData = tasks.map(t => t.status === "completed" ? 1 : 0);
    const failedData = tasks.map(t => t.status === "failed" ? 1 : 0);

    // If chart exists, update it
    if (activityChart) {
        activityChart.data.labels = labels;
        activityChart.data.datasets[0].data = completedData;
        activityChart.data.datasets[1].data = failedData;
        activityChart.update();
        return;
    }

    // Otherwise create new chart
    activityChart = new Chart(ctx, {
        type: "line",
        data: {
            labels,
            datasets: [
                {
                    label: "Completed",
                    data: completedData,
                    borderColor: "#10b981",
                    backgroundColor: "rgba(16, 185, 129, 0.2)",
                    borderWidth: 2,
                    fill: true
                },
                {
                    label: "Failed",
                    data: failedData,
                    borderColor: "#ef4444",
                    backgroundColor: "rgba(239, 68, 68, 0.2)",
                    borderWidth: 2,
                    fill: true
                }
            ]
        },
        options: {
            responsive: true,
            scales: {
                y: { beginAtZero: true }
            }
        }
    });
}
