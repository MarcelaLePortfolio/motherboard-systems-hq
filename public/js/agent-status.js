document.addEventListener('DOMContentLoaded', () => {
    const statusContainer = document.getElementById('agent-status-row');

    function getStatusClass(status) {
        switch (status.toLowerCase()) {
            case 'busy': return 'status-busy';
            case 'idle': return 'status-idle';
            case 'error': return 'status-error';
            case 'offline': return 'status-offline';
            default: return 'status-unknown';
        }
    }

    async function fetchAndRenderAgentStatus() {
        try {
            const response = await fetch('/api/agents');
            const agents = await response.json();
            
            // Clear existing status cards
            statusContainer.innerHTML = '';

            agents.forEach(agent => {
                const statusClass = getStatusClass(agent.status);
                
                const card = document.createElement('div');
                card.className = `agent-card ${statusClass}`;
                
                card.innerHTML = `
                    <div class="agent-name">${agent.agent_name}</div>
                    <div class="agent-status-text">Status: <strong>${agent.status.toUpperCase()}</strong></div>
                    <div class="agent-task">${agent.current_task || 'Awaiting assignment'}</div>
                `;
                
                statusContainer.appendChild(card);
            });

        } catch (error) {
            console.error('Error fetching agent status:', error);
            statusContainer.innerHTML = '<p style="color: red;">Agent status connection failed.</p>';
        }
    }

    // Initial fetch and set interval for refresh
    fetchAndRenderAgentStatus();
    setInterval(fetchAndRenderAgentStatus, 5000); 
});
