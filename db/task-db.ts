import { readDb } from "./db-core";
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
  const stmt = db.prepare(`SELECT status FROM tasks WHERE uuid = ?`);
  const row = stmt.get(uuid);
  return row?.status || null;
}

export function isAgentBusy(agent: string): boolean {
  const stmt = db.prepare(`SELECT status FROM agent_status WHERE agent = ?`);
  const row = stmt.get(agent);
  return row?.status === "busy";
}

export function setAgentStatus(agent: string, status: "busy" | "idle") {
  const stmt = db.prepare(`
    INSERT INTO agent_status (agent, status, ts)
    VALUES (@agent, @status, @ts)
    ON CONFLICT(agent) DO UPDATE SET status = excluded.status, ts = excluded.ts
  `);
  stmt.run({ agent, status, ts: Date.now() });
}

export function fetchAllQueuedTasks(agent: string) {
  const stmt = db.prepare(`
    SELECT * FROM tasks
    WHERE agent = ? AND status = 'queued'
    ORDER BY ts ASC
  `);
  return stmt.all(agent);
}

export function getAgentStatus(agent: string) {
  const dbJson = readDb();
  return dbJson.agents?.[agent] || "idle";
}
