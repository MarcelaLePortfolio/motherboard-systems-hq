import { drizzle } from 'drizzle-orm/better-sqlite3';
import Database from 'better-sqlite3';
import { eq } from 'drizzle-orm';
import { agentTasks } from '../../drizzle/schema';
import fs from 'fs';

const sqlite = new Database('motherboard.sqlite');
const db = drizzle(sqlite);

async function runCadeTask() {
  const [task] = await db
    .select()
    .from(agentTasks)
    .where(eq(agentTasks.agent, 'Cade'))
    .where(eq(agentTasks.status, 'Pending'))
    .limit(1);

  if (!task) return;

  console.log(`🤖 Cade executing task ${task.id}: ${task.type}`);

  if (task.type === 'read file' && task.content) {
    const content = fs.readFileSync(task.content, 'utf8');
    console.log(`📄 File content:\n${content}`);
  }

  if (task.type === 'write file' && task.content) {
    const [path, data] = task.content.split('|--|');
    fs.writeFileSync(path, data, 'utf8');
    console.log(`📝 Wrote to file: ${path}`);
  }

  if (task.type === 'append log' && task.content) {
    const logPath = 'memory/log.txt';
    const timestamp = new Date().toISOString();
    const logLine = `[${timestamp}] ${task.content}\n`;
    fs.appendFileSync(logPath, logLine, 'utf8');
    console.log(`📥 Appended to log.txt:\n${logLine}`);
  }

  if (task.type === 'patch' && task.content) {
    const [path, instruction] = task.content.split('|--|');
    const lines = fs.readFileSync(path, 'utf8').split('\n');

    const match = instruction.match(/Replace line (\d+) with: (.+)/);
    if (match) {
      const lineNumber = parseInt(match[1], 10);
      const newLine = match[2];
      if (lineNumber > 0 && lineNumber <= lines.length) {
        lines[lineNumber - 1] = newLine;
        fs.writeFileSync(path, lines.join('\n'), 'utf8');
        console.log(`🛠️ Patched line ${lineNumber} in ${path}`);
      } else {
        console.log(`⚠️ Invalid line number in patch task: ${lineNumber}`);
      }
    } else {
      console.log(`⚠️ Unsupported patch instruction format: ${instruction}`);
    }
  }

  await db.update(agentTasks)
    .set({ status: 'Complete' })
    .where(eq(agentTasks.id, task.id));

  console.log(`✅ Task ${task.id} marked complete.`);
}

setInterval(runCadeTask, 3000);
