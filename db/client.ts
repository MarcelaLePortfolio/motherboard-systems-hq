import Database from "better-sqlite3";

export const db: any = new Database('db/main.db');
export const sqlite: any = db;

export const task_events: any = { agent: { eq: () => {} }, created_at: {} };

export function pruneOldEntries(days?: number) {
  console.log("Prune old entries called with days =", days);
}
export function pruneReflections(days?: number) {
  console.log("Prune reflections called with days =", days);
}
