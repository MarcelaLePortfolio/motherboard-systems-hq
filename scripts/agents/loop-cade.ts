import { processRetryQueue } from '../utils/processRetryQueue';
import { resumeFromLastTask } from '../utils/resumeFromLastTask';
import Database from 'better-sqlite3';
import { handleTask } from './cade';

const db = new Database('db/dev.db');

async function mainLoop() {
  console.log("🌀 Cade loop tick");

  // Get multiple pending tasks, e.g., limit 5
  const tasks = db
    .prepare("SELECT * FROM agent_tasks WHERE status = 'Pending' ORDER BY id ASC LIMIT 5")
    .all();

  if (tasks.length > 0) {
    console.log(`⚙️ Processing ${tasks.length} task(s)`);

    // Mark them as In Progress first
    const markStmt = db.prepare("UPDATE agent_tasks SET status = 'In Progress' WHERE id = ?");
    const markTxn = db.transaction((ids: number[]) => {
      for (const id of ids) markStmt.run(id);
    });
    markTxn(tasks.map(t => t.id));

    // Run all tasks in parallel
    await Promise.all(
      tasks.map(async (task) => {
        try {
          const result = await handleTask(task);
          db.prepare("UPDATE agent_tasks SET status = ?, result = ? WHERE id = ?")
            .run(result.status || 'Done', result.result || '', task.id);
        } catch (err) {
          console.error(`❌ Task ${task.id} failed:`, err);
          db.prepare("UPDATE agent_tasks SET status = 'Failed', result = ? WHERE id = ?")
            .run(err.message || 'Unknown error', task.id);
        }
      })
    );
  }

  setTimeout(mainLoop, 1000);
}

mainLoop().catch(err => console.error("❌ Cade loop error:", err));