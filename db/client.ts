import Database from "better-sqlite3";
import { drizzle } from "drizzle-orm/better-sqlite3";

const dbPath = "/Users/marcela-dev/Projects/Motherboard_Systems_HQ/motherboard.sqlite";
console.log("🧩 Using SQLite database at:", dbPath);

const sqlite = new Database(dbPath, { fileMustExist: true });
export const db = drizzle(sqlite);

export function pruneReflections(days = 7) {
  const stmt = db.prepare(
    "DELETE FROM reflection_index WHERE created_at < datetime('now', '-' || ? || ' days')"
  );
  const info = stmt.run(days);
  console.log(`<0001fa9a> 🧹 Pruned ${info.changes} old reflection_index entries`);
}
