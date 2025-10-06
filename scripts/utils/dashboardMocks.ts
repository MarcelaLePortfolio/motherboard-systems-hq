import { db } from "../../db/client";
import { task_events } from "../../db/audit";

/**
 * dashboardMocks.ts (Phase 3 Upgrade)
 * --------------------------------------------------
 * Replaces mock data arrays with live DB queries.
 * Used by server.ts routes: /tasks, /logs
 * --------------------------------------------------
 */

export async function getRecentTasks(limit = 20) {
  const tasks = await db.select().from(task_events).limit(limit);
  return tasks.reverse(); // most recent first
}

export async function getRecentLogs(limit = 50) {
  const logs = await db.select().from(task_events).limit(limit);
  return logs.reverse(); // newest first
}
