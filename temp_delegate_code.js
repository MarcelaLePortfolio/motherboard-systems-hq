// Endpoint from Overview: /tasks/delegate POST
// Functionality: Acknowledges task delegation and logs the initial 'acknowledged' event 
// to task-events.log for the new stream.
app.post('/tasks/delegate', (req, res) => {
    // Expecting task_id, agent, and description in the request body
    const { task_id, agent, description } = req.body;
    
    if (!task_id || !agent || !description) {
        return res.status(400).json({ success: false, message: 'Missing required fields: task_id, agent, or description.' });
    }

    // Prepare the initial 'acknowledged' event in JSON format
    const taskEvent = {
        task_id: task_id,
        status: 'acknowledged',
        agent: agent,
        description: description,
        timestamp: new Date().toISOString()
    };
    
    const logLine = JSON.stringify(taskEvent) + '\n';
    
    // Log the event to the dedicated task log file
    fs.appendFile(TASK_LOG_FILE, logLine, (err) => {
        if (err) {
            console.error('Error writing initial task-events.log entry:', err);
            return res.status(500).json({ success: false, message: 'Delegation acknowledged, but failed to log task event for streaming.' });
        }
        
        console.log(`[TASK-LOG] Task ${task_id} acknowledged and logged.`);
        res.status(200).json({ 
            success: true, 
            message: `Task ${task_id} delegated and acknowledged.`,
            event: taskEvent 
        });
    });
});
