 
const db3 = require("db3");
const path = require("path");

const dbPath = path.join(__dirname, "../memory/agent_brain.db");
const db = new db3.Database(dbPath);

sqlite.serialize(() => {
  sqlite.run(`CREATE TABLE IF NOT EXISTS project_tracker (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent TEXT,
    task_type TEXT,
    task_summary TEXT,
    timestamp INTEGER
  )`);
});

sqlite.close();
