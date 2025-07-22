import sqlite3 from "sqlite3";
import { open } from "sqlite";
import fs from "fs/promises";

async function runEffie() {
  const db = await open({
    filename: "memory/agent_memory.db",
    driver: sqlite3.Database
  });

  const tasks = await db.all(
    `SELECT id, step FROM compiled_tasks WHERE executed = 0 ORDER BY timestamp ASC LIMIT 5`
  );

  if (tasks.length === 0) {
    console.log("🟡 Effie: No tasks to execute.");
    await db.close();
    return;
  }

  for (const task of tasks) {
    const { id, step } = task;

    let result = `🛠 Effie: Executed "${step}"`;

    // === Basic Pattern Matching ===
    if (step.toLowerCase().includes("check my disk space")) {
      const { size } = await fs.stat("/");
      result = `💾 Effie: Disk check complete. Root size approx ${size} bytes`;
    } else if (step.toLowerCase().includes("organize my screenshots")) {
      result = `🗂 Effie: Simulated organizing screenshots folder`;
    } else {
      result = `⚠️ Effie: No handler for "${step}". Skipping.`;
    }

    await db.run(`UPDATE compiled_tasks SET executed = 1 WHERE id = ?`, id);
    await db.run(`INSERT INTO logs (agent, message) VALUES (?, ?)`, 'effie', result);

    console.log(result);
  }

  await db.close();
}

runEffie().catch(console.error);
