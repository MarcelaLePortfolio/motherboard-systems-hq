import fs from 'fs';
import path from 'path';
import { handleTask } from '../agents/handleTask';

const LAST_TASK_PATH = path.resolve('memory', 'last_task.json');

export async function resumeFromLastTask() {
  if (!fs.existsSync(LAST_TASK_PATH)) return;

  try {
    const raw = fs.readFileSync(LAST_TASK_PATH, 'utf-8');
    const task = JSON.parse(raw);

    console.log('⏪ Resuming last task from crash...');
    const result = await handleTask(task);
    console.log('✅ Resume result:', result);

    // Optional: clear it after successful resume
    fs.unlinkSync(LAST_TASK_PATH);
  } catch (err: any) {
    console.error('❌ Failed to resume last task:', err.message);
  }
}
