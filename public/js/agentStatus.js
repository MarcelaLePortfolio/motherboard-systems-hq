async function refreshAgentStatus() {
  try {
    const res = await fetch('/agents/status');
    const data = await res.json();
    const container = document.querySelector('#agent-status');
    if (!container) return;

    container.innerHTML = data.agents.map(a => `
      <div class="agent ${a.status}">
        <strong>${a.name}</strong> — ${a.status.toUpperCase()}
        <br><small>CPU: ${a.cpu}% | Mem: ${a.memory} | PID: ${a.pid}</small>
      </div>
    `).join('');

  } catch (err) {
    console.error('Agent status fetch failed:', err);
  }
}

setInterval(refreshAgentStatus, 5000);
window.addEventListener('DOMContentLoaded', refreshAgentStatus);
