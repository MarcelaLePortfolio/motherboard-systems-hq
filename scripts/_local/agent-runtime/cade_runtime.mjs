import fs from "fs";
import path from "path";
import sqlite3 from "sqlite3";

const log = (msg) => console.log(`[${new Date().toISOString()}] ${msg}`);
const dbPath = path.join(__dirname, "memory/agent_brain.db");
const statePath = path.join(__dirname, "memory/agent_chain_state.json");

function main() {
  if (!fs.existsSync(statePath)) {
    log("❌ No task file found.");
    return;
  }

  const rawData = fs.readFileSync(statePath, "utf8");
  if (!rawData.trim()) {
    log("❌ Task file is empty.");
    return;
  }

  let task;
  try {
    task = JSON.parse(rawData);
  } catch (err) {
    log(`❌ Failed to parse task JSON: ${err.message}`);
    return;
  }

  const { type, summary } = task || {};
  log(`🛠 Cade received task of type: ${type}`);

  const db = new sqlite3.Database(dbPath);
  const insertStmt = `INSERT INTO project_tracker (agent, task_type, task_summary, timestamp) VALUES (?, ?, ?, ?)`;
  db.run(insertStmt, ["cade", type || "unknown", summary || "", Date.now()], function (err) {
    if (err) {
      log(`❌ Failed DB write: ${err.message}`);
    } else {
      log("✅ Task recorded in DB.");
    }
    db.close();
  });

  routeTask(type, task);
}

function routeTask(type, task) {
  switch (type) {
    case "generate_file":
      return generateFile(task);
    case "summon_agent":
      return summonAgent(task);
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

function summonAgent(task) {
  const { target, summary } = task;
  const targetPath = path.join(__dirname, `memory/${target}_chain_state.json`);

  if (!fs.existsSync(path.dirname(targetPath))) {
    log(`❌ Target memory path not found for agent: ${target}`);
    return;
  }

  const payload = {
    type: "delegated_task",
    summary: summary || `Summoned by Cade at ${new Date().toISOString()}`
  };

  fs.writeFileSync(targetPath, JSON.stringify(payload, null, 2), "utf8");
  log(`📨 Summoned ${target} with task: ${payload.summary}`);
}

main();
