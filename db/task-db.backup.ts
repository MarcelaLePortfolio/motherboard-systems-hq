import fs from "fs";
import Database from "better-sqlite3";
import { readDb } from "./db-core";
import Database from "better-sqlite3";
  const db = new Database("motherboard.db");
export { insertTask };
export function insertTaskToDb(task: { uuid: string; agent: string; type: string; content: string; status: string; created_at: number }) {
  const stmt = db.prepare(`
    INSERT OR REPLACE INTO tasks (uuid, agent, type, content, status, created_at)
    VALUES (@uuid, @agent, @type, @content, @status, @created_at)
  `);
  stmt.run(task);
}
  const stmt = db.prepare(`
    SELECT * FROM tasks
    WHERE agent = ? AND type = ? AND status = 'completed'
    ORDER BY created_at DESC
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
    INSERT INTO agent_status (agent, status, created_at)
    VALUES (@agent, @status, @created_at)
    ON CONFLICT(agent) DO UPDATE SET status = excluded.status, created_at = excluded.created_at
  `);
}

export function fetchAllQueuedTasks(agent: string) {
  const stmt = db.prepare(`
    SELECT * FROM tasks
    WHERE agent = ? AND status = 'queued'
    ORDER BY created_at ASC
  `);
  return stmt.all(agent);
}

/* <0001f9ff> Retrieve all queued tasks */
export function getQueuedTasks() {
  const stmt = db.prepare(`
    SELECT * FROM tasks
    WHERE status = 'queued'
    ORDER BY created_at ASC
  `);
  return stmt.all();
}/* <0001fa02> Update task status */
export function updateTaskStatus(uuid: string, status: string) {
  const stmt = db.prepare(`
    UPDATE tasks
    SET status = @status
    WHERE uuid = @uuid
  `);

}

export function getAgentStatus(agent: string): string {
  try {
    const raw = fs.readFileSync("memory/agent_chain_state.json", "utf8");
    const state = JSON.parse(raw);
    console.log("🔍 Read agent state file:", state);
    if (typeof state.agent === "string" && typeof state.status === "string") {
      return state.agent.toLowerCase() === agent.toLowerCase() ? state.status : "idle";
    } else {
      console.warn("⚠️ Agent state file missing expected fields.");
      return "idle";
    }
  } catch (err) {
    console.error("❌ Failed to read or parse agent state:", err);
    return "idle";
  }
}


/* <0001fa04> Delete completed task by UUID */
export function deleteCompletedTask(uuid: string) {
  const stmt = db.prepare(`
    DELETE FROM tasks
    WHERE uuid = @uuid AND status = 'complete'
  `);
  stmt.run({ uuid });
}
