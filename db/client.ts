// <0001fb35> Drizzle sql.js client (CJS-compatible async resolver)
import initSqlJs from "sql.js";
import fs from "fs";
import type { SQLJsDatabase } from "drizzle-orm/sql-js";
import path from "path";
import { drizzle } from "drizzle-orm/sql-js";

const dbPath = path.resolve("db/local.sqlite");

let dbInstance: SQLJsDatabase | null = null;

export const dbPromise = (async () => {
  const SQL = await initSqlJs();
  const exists = fs.existsSync(dbPath);
  const fileBuffer = exists ? fs.readFileSync(dbPath) : null;
  const sqlJsDB = fileBuffer ? new SQL.Database(fileBuffer) : new SQL.Database();

  console.log(
    exists
      ? "📂 Loaded existing db/local.sqlite database"
      : "🆕 Created new db/local.sqlite database"
  );

  // Persist database on exit
  process.on("exit", () => {
    const data = sqlJsDB.export();
    fs.writeFileSync(dbPath, Buffer.from(data));
    console.log("💾 Persisted db/local.sqlite before exit");
  });

  dbInstance = drizzle(sqlJsDB);
  return dbInstance;
})();

// ✅ Safe getter for synchronous modules
export function getDb() {
  if (!dbInstance) throw new Error("Database not ready yet. Await dbPromise first.");
  return dbInstance;
}

console.log("<0001fb35> Drizzle sql.js client bootstrapping async...");
