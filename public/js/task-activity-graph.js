document.addEventListener('DOMContentLoaded', () => {
    const ctx = document.getElementById('task-activity-graph').getContext('2d');
    let activityChart;

    async function fetchAndRenderGraph() {
        try {
            const response = await fetch('/api/activity-graph');
            const data = await response.json();

            // Process data for Chart.js
            const labels = data.map(entry => {
                // Format timestamp to simple time (e.g., 10:30:05)
                const date = new Date(entry.timestamp);
                return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
            });

            const completedData = data.map(entry => entry.tasks_completed);
            const failedData = data.map(entry => entry.tasks_failed);

            if (activityChart) {
                // Update existing chart data without destroying animation
                activityChart.data.labels = labels;
                activityChart.data.datasets[0].data = completedData;
                activityChart.data.datasets[1].data = failedData;
                activityChart.update();
            } else {
                // Initialize new chart
                activityChart = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [
                            {
                                label: 'Tasks Completed',
                                data: completedData,
                                borderColor: '#4caf50', // Green
                                backgroundColor: 'rgba(76, 175, 80, 0.1)',
                                tension: 0.4,
                                fill: true
                            },
                            {
                                label: 'Tasks Failed',
                                data: failedData,
                                borderColor: '#f44336', // Red
                                backgroundColor: 'rgba(244, 67, 54, 0.1)',
                                tension: 0.4,
                                fill: true
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        animation: { duration: 0 }, // Disable animation for smoother updates
                        interaction: {
                            mode: 'index',
                            intersect: false,
                        },
                        plugins: {
                            legend: { labels: { color: '#ccc' } }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                grid: { color: '#333' },
                                ticks: { color: '#aaa' }
                            },
                            x: {
                                grid: { color: '#333' },
                                ticks: { color: '#aaa' }
                            }
                        }
                    }
                });
            }
        } catch (error) {
            console.error('Error fetching graph data:', error);
        }
    }

    // Initial fetch
    fetchAndRenderGraph();

    // Refresh graph every 5 seconds
    setInterval(fetchAndRenderGraph, 5000);
});
