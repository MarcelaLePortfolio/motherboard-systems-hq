import { drizzle } from 'drizzle-orm/better-sqlite3';
import Database from 'better-sqlite3';
import { eq } from 'drizzle-orm';
import { agentTasks } from '../../drizzle/schema';
import fs from 'fs';
import { execSync } from 'child_process';

const sqlite = new Database('motherboard.sqlite');
const db = drizzle(sqlite);

async function runCadeTask() {
  try {
    const [task] = await db
      .select()
      .from(agentTasks)
      .where(eq(agentTasks.agent, 'Cade'))
      .where(eq(agentTasks.status, 'Pending'))
      .limit(1);
  if ((task.retry_count || 0) >= 3) {n    console.log(`🚫 Task ${task.id} exceeded retry limit.`);n    await db.update(agentTasks)n      .set({ status: 'Failed' })n      .where(eq(agentTasks.id, task.id));n    return;n  }
  if ((task.retry_count || 0) >= 3) {n    console.log(`🚫 Task ${task.id} exceeded retry limit.`);n    await db.update(agentTasks)n      .set({ status: 'Failed' })n      .where(eq(agentTasks.id, task.id));n    return;n  }

    if (!task) {
  console.log(`�� Pulled task ${task.id} with retry_count=${task.retry_count}`);n  if ((task.retry_count || 0) >= 3) {n    console.log(`🚫 Task ${task.id} exceeded retry limit.`);n    await db.update(agentTasks)n      .set({ status: 'Failed' })n      .where(eq(agentTasks.id, task.id));n    return;n  }
  console.log(`�� Pulled task ${task.id} with retry_count=${task.retry_count}`);n
  console.log(`😴 No pending task. Waiting...`);
  await new Promise((r) => setTimeout(r, 3000));
  return;
}


    try {
      if (task.type === 'read file' && task.content) {
        const content = fs.readFileSync(task.content, 'utf8');
        console.log(`📄 File content:\n${content}`);
      }

      else if (task.type === 'write file' && task.content) {
        const [path, data] = task.content.split('|--|');
        fs.writeFileSync(path, data, 'utf8');
        console.log(`📝 Wrote to file: ${path}`);
      }

      else if (task.type === 'append log' && task.content) {
        const logPath = 'memory/log.txt';
        const timestamp = new Date().toISOString();
        const logLine = `[${timestamp}] ${task.content}\n`;
        fs.appendFileSync(logPath, logLine, 'utf8');
        console.log(`📥 Appended to log.txt:\n${logLine}`);
      }

      else if (task.type === 'patch' && task.content) {
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

      else if (task.type === 'run command' && task.content) {
        try {
          const output = execSync(task.content, { encoding: 'utf8' });
          console.log(`💻 Ran command: ${task.content}`);
          console.log(`📤 Output:\n${output}`);
          fs.appendFileSync('memory/log.txt', `[${new Date().toISOString()}] Ran: ${task.content}\nOutput:\n${output}\n\n`);
        } catch (err) {
          const errorOutput = err.message || 'Unknown error';
          console.log(`❌ Error running command: ${task.content}`);
          console.log(`📛 Error:\n${errorOutput}`);
          fs.appendFileSync('memory/log.txt', `[${new Date().toISOString()}] Failed: ${task.content}\nError:\n${errorOutput}\n\n`);
        }
      }

      await db.update(agentTasks)
        .set({ status: 'Complete' })
        .where(eq(agentTasks.id, task.id));

      console.log(`✅ Task ${task.id} marked complete.`);

      const tickerLine = `[${new Date().toISOString()}] Cade completed task ${task.id}: ${task.type}`;
      fs.appendFileSync('memory/ticker.log', tickerLine + '\n', 'utf8');

    } catch (err) {
      const errorMsg = `🔥 Task ${task.id} (${task.type}) failed with error:\n${err.stack || err}`;
      console.error(errorMsg);
      fs.appendFileSync('memory/log.txt', `[${new Date().toISOString()}] ${errorMsg}\n\n`);
      fs.appendFileSync('memory/ticker.log', `[${new Date().toISOString()}] ❌ Cade failed task ${task.id}: ${task.type}\n`, 'utf8');
    }

  } catch (fatal) {
    const fallbackMsg = `🚨 Fatal error in Cade task loop:\n${fatal.stack || fatal}`;
    console.error(fallbackMsg);
    fs.appendFileSync('memory/log.txt', `[${new Date().toISOString()}] ${fallbackMsg}\n\n`);
    fs.appendFileSync('memory/ticker.log', `[${new Date().toISOString()}] ❌ Cade encountered fatal runtime error\n`, 'utf8');
  }
}

setInterval(runCadeTask, 3000);