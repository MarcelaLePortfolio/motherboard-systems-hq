import initSqlJs from "sql.js";
import fs from "fs";
import path from "path";
import { drizzle } from "drizzle-orm/sql-js";

const dbPath = path.resolve("db/local.sqlite");

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
  });

  // Wrap SQL.js database in Drizzle ORM
  const db = drizzle(sqlJsDB);
  return db;
})();
