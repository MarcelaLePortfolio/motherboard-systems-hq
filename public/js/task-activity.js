// This script initializes the Task Activity Chart using Chart.js.

// Note: We use the global Chart object provided by the Chart.js CDN (chart.umd.js).

document.addEventListener('DOMContentLoaded', () => {
    const ctx = document.getElementById('task-activity-graph').getContext('2d');

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00'],
            datasets: [{
                label: 'Tasks Completed',
                data: [12, 19, 3, 5, 2, 3, 7],
                borderColor: 'rgba(75, 192, 192, 1)',
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                borderWidth: 1
            },
            {
                label: 'Tasks Delegated',
                data: [8, 11, 2, 4, 1, 2, 5],
                borderColor: 'rgba(255, 159, 64, 1)',
                backgroundColor: 'rgba(255, 159, 64, 0.2)',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
});
