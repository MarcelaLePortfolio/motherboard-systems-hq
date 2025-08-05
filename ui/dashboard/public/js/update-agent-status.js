async function refreshAgentStatus() {
  try {
    const res = await fetch('agent-status.json?cache=' + Date.now());
    const statuses = await res.json();
    const container = document.getElementById('agent-status');
    container.innerHTML = '';

    statuses.forEach(agent => {
      const dot = document.createElement('span');
      dot.textContent = `${agent.status === 'online' ? '🟢' : '⚪'} ${agent.name}`;
      dot.style.marginRight = '16px';
      container.appendChild(dot);
    });
  } catch (e) {
    console.error('Failed to fetch agent-status.json', e);
  }
}

setInterval(refreshAgentStatus, 3000);
refreshAgentStatus();
