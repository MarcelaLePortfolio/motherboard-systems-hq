import Database from 'better-sqlite3';
import { handleTask } from './cade';

const db = new Database('db/dev.db');

async function mainLoop() {
  console.log("🌀 Cade loop tick");

  const task = db
    .prepare("SELECT * FROM agent_tasks WHERE status = 'Pending' ORDER BY id ASC LIMIT 1")
    .get();

  if (task) {
    console.log(`🤖 Cade executing task ${task.id}: ${task.type}`);

    const result = await handleTask(task);
    db.prepare("UPDATE agent_tasks SET status = ?, result = ? WHERE id = ?")
      .run(result.status || 'Done', result.result || '', task.id);
  }

  setTimeout(mainLoop, 1000);
}

mainLoop().catch(err => console.error("❌ Cade loop error:", err));
