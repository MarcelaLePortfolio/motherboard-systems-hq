import Database from 'better-sqlite3';

const db = new Database('motherboard.db');

export function insertTaskToDb(task: {
  uuid: string;
  agent: string;
  type: string;
  content: string;
  status: string;
  ts: number;
}) {
  const stmt = db.prepare(`
    INSERT OR REPLACE INTO tasks (uuid, agent, type, content, status, ts)
    VALUES (@uuid, @agent, @type, @content, @status, @ts)
  `);
  stmt.run(task);
}

export function fetchLatestCompletedTask(agent: string, type: string) {
  const stmt = db.prepare(`
    SELECT * FROM tasks
    WHERE agent = ? AND type = ? AND status = 'completed'
    ORDER BY ts DESC
    LIMIT 1
  `);
  return stmt.get(agent, type);
}

export function storeTaskResult(uuid: string, result: any) {
  const stmt = db.prepare(`
    UPDATE tasks
    SET status = 'completed', result = @result
    WHERE uuid = @uuid
  `);
  stmt.run({ uuid, result: JSON.stringify(result) });
}

export function fetchTaskStatus(uuid: string) {
  const stmt = db.prepare(`
    SELECT status FROM tasks WHERE uuid = ?
  `);
  const row = stmt.get(uuid);
  return row?.status || null;
}
