// scripts/agents/cade.ts
import fs from 'fs';
import path from 'path';
import { generateDiff } from '../utils/diff';
import {
  updateTaskStatus,
  deleteCompletedTask,
  setAgentStatus
} from '../../db/task-db';

export async function cadeCommandRouter(command: string, task?: any) {
  if (command === 'execute' && task) {
    await handleTask(task);
    return { status: 'ok', message: 'Executed task' };
  }
  return { status: 'error', message: 'Unknown command' };
}

export async function handleTask(task: any) {
  const { uuid, type, content, agent, payload } = task;
  console.log(`🧠 Cade received task:`, task);

  setAgentStatus(agent, 'busy'); // 👷 Mark agent as busy

  try {
    let result = '';

    switch (type) {
      case 'say_hello': {
        console.log(`🗣️ Cade says: ${content}`);
        result = `Said hello with: ${content}`;
        break;
      }

      case 'patch': {
        if (!payload?.path || !payload?.content) {
          throw new Error('Missing payload path or content.');
        }

        const absPath = path.resolve(payload.path);
        if (!absPath.startsWith(process.cwd())) {
          throw new Error('Unsafe file path.');
        }

        const existing = fs.existsSync(absPath)
          ? fs.readFileSync(absPath, 'utf8')
          : '';

        const patched = existing + payload.content;
        fs.writeFileSync(absPath, patched, 'utf8');

        const diff = generateDiff(existing, patched);
        fs.appendFileSync(
          'logs/ops-stream.log',
          `\n🛠️ PATCH: ${payload.path}\n${diff}\n`
        );

        result = `<0001fa79> Patched ${payload.path}:\n${diff}`;
        break;
      }

      default: {
        console.log(`⚠️ Unknown task type: ${type}`);
        result = `Unknown task type: ${type}`;
      }
    }

    updateTaskStatus(uuid, 'completed');
    deleteCompletedTask(uuid);
    console.log(`✅ Task completed: ${uuid}\n${result}`);
  } catch (err: any) {
    console.error(`❌ Error executing task ${uuid}:`, err.message);
    updateTaskStatus(uuid, 'failed');
  } finally {
    setTimeout(() => setAgentStatus(agent, 'idle'), 100); // Restore to idle
  }
}