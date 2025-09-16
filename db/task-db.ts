import fs from "fs";
import Database from "better-sqlite3";
import { readDb } from "./db-core";
import Database from "better-sqlite3";
  const db = new Database("motherboard.db");

/* <0001fa03> Insert task into queue */
const insertTask = (task: any) => {
  const insert = db.prepare(`
    INSERT INTO tasks (uuid, type, content, agent, status, created_at, triggered_by, path)
    VALUES (@uuid, @type, @content, @agent, @status, @created_at, @triggered_by, @path)
  `);
  insert.run(task);
};

export { insertTask };

/* <0001fa04> Delete completed task by UUID */


/* <0001fa04> Delete completed task by UUID */
function deleteCompletedTask(uuid: string) {
  const stmt = db.prepare(`
    DELETE FROM tasks
    WHERE uuid = @uuid AND status = 'complete'
  `);
  stmt.run({ uuid });
}

export { deleteCompletedTask };

/* <0001fa05> Update agent status in agent_status table */


/* <0001fa05> Update agent status in agent_status table */
function setAgentStatus(agent: string, status: string) {
  const now = Date.now();
  const stmt = db.prepare(`
    INSERT INTO agent_status (agent, status, created_at, updated_at)
    VALUES (?, ?, ?, ?)
    ON CONFLICT(agent) DO UPDATE SET
      status = excluded.status,
      updated_at = excluded.updated_at
  `);
  stmt.run(agent, status, now, now);
}

export { setAgentStatus };

/* <0001fa06> Update task status by UUID */


/* <0001fa06> Update task status by UUID */


/* <0001fa06> Update task status by UUID */


/* <0001fa06> Update task status by UUID */


/* <0001fa06> Update task status by UUID */
function updateTaskStatus(uuid: string, status: string) {
  const stmt = db.prepare(`
    UPDATE tasks
    SET status = @status
    WHERE uuid = @uuid
  `);
  stmt.run({ uuid, status });
}

export { updateTaskStatus };

/* <0001fa07> Get current status of agent from agent_status table */
function getAgentStatus(agent: string): string | null {
  const stmt = db.prepare(`
    SELECT status FROM agent_status
    WHERE agent = ?
    ORDER BY updated_at DESC
    LIMIT 1
  `);
  const row = stmt.get(agent);
  return row ? row.status : null;
}

export { getAgentStatus };

/* <0001fa08> Get all queued tasks from tasks table */
function getQueuedTasks(): any[] {
  const stmt = db.prepare(`
    SELECT * FROM tasks
    WHERE status = 'queued'
    ORDER BY created_at ASC
  `);
  return stmt.all();
}

export { getQueuedTasks };
