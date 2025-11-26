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

