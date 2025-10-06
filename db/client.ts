import initSqlJs from "sql.js";
import fs from "fs";
import path from "path";

const dbPath = path.resolve("db/local.sqlite");

export const dbPromise = (async () => {
  const SQL = await initSqlJs();
  const exists = fs.existsSync(dbPath);
  const fileBuffer = exists ? fs.readFileSync(dbPath) : null;
  const db = fileBuffer ? new SQL.Database(fileBuffer) : new SQL.Database();

  console.log(exists
    ? "📂 Loaded existing db/local.sqlite database"
    : "🆕 Created new db/local.sqlite database");

  // Persist on exit
  process.on("exit", () => {
    const data = db.export();
    fs.writeFileSync(dbPath, Buffer.from(data));
  });

  return db;
})();
