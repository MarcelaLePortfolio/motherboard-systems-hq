
-- AGENT STATUS SCHEMA
CREATE TABLE IF NOT EXISTS agent_status (
    id SERIAL PRIMARY KEY,
    agent_name VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL, -- 'IDLE', 'BUSY', 'OFFLINE', 'ERROR'
    current_task VARCHAR(100),
    last_heartbeat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- DUMMY AGENT DATA
INSERT INTO agent_status (agent_name, status, current_task) VALUES
('Agent-Alpha', 'BUSY', 'Processing Data Batch A'),
('Agent-Beta', 'IDLE', 'Waiting for tasks'),
('Agent-Gamma', 'OFFLINE', 'Connection lost'),
('Agent-Delta', 'ERROR', 'Memory Overflow Exception');
