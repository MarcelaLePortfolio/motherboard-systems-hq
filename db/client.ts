import initSqlJs from "sql.js";
import { drizzle } from "drizzle-orm/sql-js";
import fs from "fs";

export let persistToDisk: () => void;

export const dbPromise = (async () => {
  try {
    const SQL = await initSqlJs({
      locateFile: (file: string) => `node_modules/sql.js/dist/${file}`,
    });

    const dbPath = "db/local.sqlite";
    let sqlite;

    if (fs.existsSync(dbPath)) {
      const fileBuffer = fs.readFileSync(dbPath);
      sqlite = new SQL.Database(fileBuffer);
      console.log("📂 Loaded existing local.sqlite database");
    } else {
      sqlite = new SQL.Database();
      console.log("🆕 Created new in-memory database");
    }

    sqlite.run(`
      CREATE TABLE IF NOT EXISTS task_events (
        id TEXT PRIMARY KEY NOT NULL,
        task_id TEXT,
        type TEXT,
        status TEXT,
        actor TEXT,
        payload TEXT,
        result TEXT,
        file_hash TEXT,
        created_at TEXT
      );
    `);

    sqlite.run(`
      CREATE TABLE IF NOT EXISTS skills (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT,
        description TEXT,
        code TEXT,
        created_at TEXT
      );
    `);

    // ✅ Exported persistence helper
    persistToDisk = () => {
      const data = sqlite.export();
      fs.writeFileSync(dbPath, Buffer.from(data));
    };

    const dbInstance = drizzle(sqlite);
    console.log("✅ Using sql.js (pure JS / persistent build)");
    return dbInstance;
  } catch (err) {
    console.error("❌ Failed to initialize sql.js:", err);
    process.exit(1);
  }
})();
