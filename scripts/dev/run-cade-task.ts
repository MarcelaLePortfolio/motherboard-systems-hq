import { drizzle } from 'drizzle-orm/better-sqlite3';
import Database from 'better-sqlite3';
import { eq } from 'drizzle-orm';
import { agentTasks } from '../../drizzle/schema';
import fs from 'fs';

const sqlite = new Database('motherboard.sqlite');
const db = drizzle(sqlite);

// Step 1: Fetch first pending task for Cade
const [task] = await db
  .select()
  .from(agentTasks)
  .where(eq(agentTasks.agent, 'Cade'))
  .where(eq(agentTasks.status, 'Pending'))
  .limit(1);

if (!task) {
  console.log('🟡 No pending tasks for Cade.');
  process.exit(0);
}

console.log(`🧠 Cade executing task ${task.id}: ${task.type}`);

if (task.type === 'read file' && task.content) {
  const content = fs.readFileSync(task.content, 'utf8');
  console.log(`📄 File content:\n${content}`);
}

// Step 2: Mark task as complete
await db.update(agentTasks)
  .set({ status: 'Complete' })
  .where(eq(agentTasks.id, task.id));

console.log(`✅ Task ${task.id} marked complete.`);
