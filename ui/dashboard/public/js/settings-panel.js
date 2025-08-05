async function controlAgent(agentName, action) {
  try {
    const res = await fetch(`/api/control-agent`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ agent: agentName, action })
    });

    const result = await res.json();
    console.log(`🛠️ ${agentName} ${action}:`, result.message);

    // Refresh agent-status.json after control action
    setTimeout(() => {
      fetch('agent-status.json?cache=' + Date.now())
        .then(res => res.json())
        .then(statuses => {
          const container = document.getElementById('agent-status');
          container.innerHTML = '';
          statuses.forEach(agent => {
            const dot = document.createElement('span');
            dot.textContent = `${agent.status === 'online' ? '🟢' : '⚪'} ${agent.name}`;
            dot.style.marginRight = '16px';
            container.appendChild(dot);
          });
        });
    }, 1000);
  } catch (err) {
    console.error(`❌ Failed to ${action} ${agentName}:`, err);
  }
}
