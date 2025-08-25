import Database from "better-sqlite3";
import { readDb } from "./db-core";
import Database from "better-sqlite3";
  const db = new Database("motherboard.db");
export function insertTaskToDb(task: { uuid: string; agent: string; type: string; content: string; status: string; ts: number }) {
  const stmt = db.prepare(`
    INSERT OR REPLACE INTO tasks (uuid, agent, type, content, status, ts)
    VALUES (@uuid, @agent, @type, @content, @status, @ts)
  `);
  stmt.run(task);
}
  const stmt = db.prepare(`
    SELECT * FROM tasks
    WHERE agent = ? AND type = ? AND status = 'completed'
    ORDER BY ts DESC
    LIMIT 1
  `);

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

}
/* <0001f9ff> Retrieve all queued tasks */
export function getQueuedTasks() {
  const stmt = db.prepare(`
    SELECT * FROM tasks
    WHERE status = 'queued'
    ORDER BY ts ASC
  `);
  return stmt.all();
}/* <0001fa02> Update task status */
export function updateTaskStatus(uuid: string, status: string) {
  const stmt = db.prepare(`
    UPDATE tasks
    SET status = @status
    WHERE uuid = @uuid
  `);
  stmt.run({ uuid, status });
}

/* <0001fa03> Auto-delete completed task */
export function deleteCompletedTask(uuid: string) {
  const db = new Database("motherboard.db");
  db.prepare(`DELETE FROM tasks WHERE uuid = ? AND status = 'completed'`).run(uuid);
}
