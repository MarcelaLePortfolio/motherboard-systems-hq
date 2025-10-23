document.addEventListener("DOMContentLoaded", async () => {
  console.log("📋 DOM fully loaded — dashboard.js executing safely");

document.addEventListener("DOMContentLoaded", () => {

async function loadRecentTasks() {
  const res = await fetch('/tasks/recent');
  const data = await res.json();
  const panel = document.getElementById('recent-tasks');
  panel.innerHTML = `
    <table>
      <thead><tr><th>Type</th><th>Status</th><th>Actor</th><th>Result</th><th>Time</th></tr></thead>
      <tbody>${data.rows.map(r => `
        <tr>
          <td>${r.type}</td>
          <td>${r.status}</td>
          <td>${r.actor}</td>
          <td>${r.result}</td>
          <td>${new Date(r.created_at).toLocaleString()}</td>
        </tr>
      `).join('')}</tbody>
    </table>
  `;
}
window.addEventListener('DOMContentLoaded', loadRecentTasks);
});
});
