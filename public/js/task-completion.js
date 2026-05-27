document.addEventListener('DOMContentLoaded', () => {
    const completeBtn = document.getElementById('complete-task-btn');
    const messageDisplay = document.getElementById('task-delegate-message'); // Reuse the existing message display

    // We'll hardcode 'Agent Alpha' for initial testing.
    const AGENT_TO_COMPLETE = 'Agent Alpha'; 

    completeBtn.addEventListener('click', async () => {
        completeBtn.disabled = true;
        messageDisplay.style.color = 'orange';
        messageDisplay.textContent = `Attempting to complete task for ${AGENT_TO_COMPLETE}...`;

        try {
            const response = await fetch('/api/complete-task', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ agentName: AGENT_TO_COMPLETE }) 
            });

            const data = await response.json();

            if (response.ok) {
                messageDisplay.style.color = '#1E90FF'; // Dodger Blue
                messageDisplay.textContent = data.message;
            } else {
                messageDisplay.style.color = 'red';
                messageDisplay.textContent = `Failure: ${data.message || 'Task completion failed.'}`;
            }

        } catch (error) {
            console.error('Task completion API call failed:', error);
            messageDisplay.style.color = 'red';
            messageDisplay.textContent = 'Completion failed due to network error.';
        } finally {
            completeBtn.disabled = false;
        }
    });
});
