// <0001fb45> Clean dashboardMocks with proper getDb integration
import { getDb } from "../../db/client";
import { task_events } from "../../db/audit";

export async function getRecentTasks(limit = 10) {
  const db = getDb();
  const tasks = await db.select().from(task_events).limit(limit);
  return tasks.reverse(); // most recent first
}

export async function getRecentLogs(limit = 10) {
  const db = getDb();
  const logs = await db.select().from(task_events).limit(limit);
  return logs.reverse(); // newest first
}
