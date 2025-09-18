import Database from "better-sqlite3";
const db = new Database("motherboard.db");

// Insert task
export const insertTask = (task) => {
  const stmt = db.prepare(`
    INSERT INTO tasks (uuid, type, content, agent, status, created_at, triggered_by, path)
    VALUES (@uuid, @type, @content, @agent, @status, @created_at, @triggered_by, @path)
  `);
  stmt.run(task);
};

// Delete completed task
export const deleteCompletedTask = (uuid) => {
  const stmt = db.prepare(`
    DELETE FROM tasks
    WHERE uuid = @uuid AND status = 'complete'
  `);
  stmt.run({ uuid });
};

// Update agent status
export const setAgentStatus = (agent, status) => {
  const now = Date.now();
  const stmt = db.prepare(`
    INSERT INTO agent_status (agent, status, created_at, updated_at)
    VALUES (?, ?, ?, ?)
    ON CONFLICT(agent) DO UPDATE SET
      status = excluded.status,
      updated_at = excluded.updated_at
  `);
  stmt.run(agent, status, now, now);
};

// Update task status
export const updateTaskStatus = (uuid, status) => {
  const stmt = db.prepare(`UPDATE tasks SET status = @status WHERE uuid = @uuid`);
  stmt.run({ uuid, status });
};

// Get agent status
export const getAgentStatus = (agent) => {
  const stmt = db.prepare(`SELECT status FROM agent_status ORDER BY updated_at DESC LIMIT 1`);
  const row = stmt.get(agent);
  return row ? row.status : null;
};

// Get queued tasks
export const getQueuedTasks = () => {
  const stmt = db.prepare(`SELECT * FROM tasks WHERE status = 'queued' ORDER BY created_at ASC`);
  return stmt.all();
};

// Get latest completed task
export const fetchLatestCompletedTask = () => {
  const stmt = db.prepare(`SELECT * FROM tasks WHERE status = 'complete' ORDER BY created_at DESC LIMIT 1`);
  return stmt.get();
};

// Matilda helper to fetch latest task for an agent
export const fetchTaskStatus = (agent) => {
  const stmt = db.prepare(`
    SELECT * FROM tasks
    WHERE agent = @agent
    ORDER BY created_at DESC
    LIMIT 1
  `);
  return stmt.get({ agent });
};
