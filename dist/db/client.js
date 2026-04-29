import Database from "better-sqlite3";
export const db = new Database('db/main.db');
export const sqlite = db;
export const task_events = db.prepare("SELECT * FROM task_events");
export function pruneOldEntries(days) {
    // Example prune logic
    console.log("Prune old entries called with days =", days);
}
export function pruneReflections(days) {
    console.log("Prune reflections called with days =", days);
}
