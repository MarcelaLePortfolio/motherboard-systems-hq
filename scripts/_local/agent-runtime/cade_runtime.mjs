import fs from "fs";
import path from "path";
import sqlite3 from "sqlite3";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const dbPath = path.join(__dirname, "memory", "agent_brain.db");

function log(msg) {
  console.log(`[${new Date().toISOString()}] ${msg}`);
}

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    log(`❌ Failed to open DB: ${err.message}`);
    process.exit(1);
  }
  log(`DB ready at ${dbPath}`);
  continueRuntime();
});

function continueRuntime() {
  const statePath = path.join(__dirname, "memory", "agent_chain_state.json");
  if (!fs.existsSync(statePath)) {
    log("No task file found for Cade.");
    return;
  }

  let task;
  try {
    const rawData = fs.readFileSync(statePath, "utf8");
    log(`Read task data: ${rawData}`);
    task = JSON.parse(rawData);
  } catch (err) {
    log(`❌ Failed to parse task JSON: ${err.message}`);
    return;
  }

  log(`🛠 Cade received task of type: ${task?.type || 'N/A'}`);

  const insertStmt = `INSERT INTO project_tracker (agent, task_type, task_summary, timestamp) VALUES (?, ?, ?, ?)`;
  db.run(insertStmt, ["cade", task?.type || "unknown", task?.summary || "", Date.now()], function (err) {
    if (err) {
      log(`❌ Failed DB write: ${err.message}`);
    } else {
      log("✅ Task recorded in DB.");
    }
  });
}
