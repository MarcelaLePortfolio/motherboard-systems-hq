import pg from 'pg';
const { Pool } = pg;

const pool = new Pool({
  user: process.env.POSTGRES_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost', // Use localhost if running script from host machine
  database: process.env.POSTGRES_DB || 'dashboard_db',
  password: process.env.POSTGRES_PASSWORD || 'password',
  port: 5432,
});

const sql = `
CREATE TABLE IF NOT EXISTS agent_status (
    id SERIAL PRIMARY KEY,
    agent_name VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    current_task VARCHAR(100),
    last_heartbeat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELETE FROM agent_status; -- Clear old data to prevent duplicates during dev

INSERT INTO agent_status (agent_name, status, current_task) VALUES
('Agent-Alpha', 'BUSY', 'Processing Data Batch A'),
('Agent-Beta', 'IDLE', 'Waiting for tasks'),
('Agent-Gamma', 'OFFLINE', 'Connection lost'),
('Agent-Delta', 'ERROR', 'Memory Overflow Exception');
`;

async function seed() {
    try {
        await pool.query(sql);
        console.log("✅ Agent table created and seeded.");
    } catch (err) {
        console.error("❌ Error seeding agents:", err);
    } finally {
        await pool.end();
    }
}

seed();
