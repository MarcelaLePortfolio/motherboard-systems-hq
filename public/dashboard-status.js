// 🔄 Live Agent Status updater
async function loadAgentStatus() {
  try {
    const res = await fetch('/agents');
    const data = await res.json();
    const panel = document.getElementById('agent-status');
    panel.innerHTML = `
      <table>
        <thead><tr><th>Agent</th><th>Status</th></tr></thead>
        <tbody>${Object.entries(data)
          .map(([name, info]) => `
            <tr>
              <td>${name}</td>
              <td>${info.status}</td>
            </tr>
          `)
          .join('')}</tbody>
      </table>
    `;
  } catch (err) {
    console.error('❌ Failed to load agent status:', err);
  }
}

// Auto-refresh every 5 seconds
window.addEventListener('DOMContentLoaded', () => {
  loadAgentStatus();
  setInterval(loadAgentStatus, 5000);
});
