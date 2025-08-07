import fs from "fs";
import path from "path";
import sqlite3 from "sqlite3";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function log(msg) {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${msg}`);
}

const dbPath = path.join(__dirname, "memory", "agent_brain.db");
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

  const { type, summary } = task || {};
  log(`🛠 Cade received task of type: ${type}`);

  const insertStmt = `INSERT INTO project_tracker (agent, task_type, task_summary, timestamp) VALUES (?, ?, ?, ?)`;
  db.run(insertStmt, ["cade", type || "unknown", summary || "", Date.now()], function (err) {
    if (err) {
      log(`❌ Failed DB write: ${err.message}`);
    } else {
      log("✅ Task recorded in DB.");
    }
  });

  routeTask(type, task);
}

function routeTask(type, task) {
  switch (type) {
    case "generate_file":
      return generateFile(task);
    default:
      log(`⚠️ No handler for task type: ${type}`);
  }
}

function generateFile(task) {
  const outputDir = path.join(__dirname, "output");
  const outputPath = path.join(outputDir, "agent_onboarding.txt");

  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);

  const contents = `Welcome to Motherboard Systems HQ, Agent!\n\nThis guide will help you integrate smoothly into the system.\n\n🧠 Summary: ${task.summary || "No summary provided"}\n\n- Report to Matilda for delegation\n- Use Cade for backend tasks\n- Use Effie for local operations\n\nStay sharp.\n— HQ`;

  fs.writeFileSync(outputPath, contents, "utf8");
  log(`📄 File generated at ${outputPath}`);
}
