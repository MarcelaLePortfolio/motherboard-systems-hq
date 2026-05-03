document.addEventListener('DOMContentLoaded', () => {
    const delegateBtn = document.getElementById('delegate-task-btn');
    const messageDisplay = document.getElementById('task-delegate-message');

    delegateBtn.addEventListener('click', async () => {
        delegateBtn.disabled = true;
        messageDisplay.style.color = 'yellow';
        messageDisplay.textContent = 'Searching for an IDLE agent...';

        try {
            const response = await fetch('/api/delegate-task', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                // Optional: send a custom task description
                body: JSON.stringify({ task: 'Execute core diagnostic scan' }) 
            });

            const data = await response.json();

            if (response.ok) {
                messageDisplay.style.color = '#4CAF50';
                messageDisplay.textContent = `Success! Assigned task "${data.agent.current_task}" to Agent ${data.agent.agent_name}.`;
            } else {
                messageDisplay.style.color = 'red';
                messageDisplay.textContent = `Failure: ${data.message || 'No IDLE agents available.'}`;
            }

        } catch (error) {
            console.error('Delegation API call failed:', error);
            messageDisplay.style.color = 'red';
            messageDisplay.textContent = 'Delegation failed due to network error.';
        } finally {
            delegateBtn.disabled = false;
        }
    });
});
