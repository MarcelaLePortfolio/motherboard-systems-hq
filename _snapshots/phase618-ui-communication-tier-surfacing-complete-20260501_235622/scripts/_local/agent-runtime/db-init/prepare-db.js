 
const sqlite3 = require("sqlite3");
const path = require("path");

const dbPath = path.join(__dirname, "../memory/agent_brain.db");
const db = new sqlite3.Database(dbPath);

db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS project_tracker (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent TEXT,
    task_type TEXT,
    task_summary TEXT,
    timestamp INTEGER
  )`);
});

db.close();
