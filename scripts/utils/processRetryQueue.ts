import fs from 'fs';
import path from 'path';
import { handleTask } from '../agents/handleTask';

const QUEUE_PATH = path.resolve('memory', 'retry_queue.json');

export async function processRetryQueue() {
  if (!fs.existsSync(QUEUE_PATH)) return;

  try {
    const raw = fs.readFileSync(QUEUE_PATH, 'utf-8');
    const queue = JSON.parse(raw);
    if (!Array.isArray(queue) || queue.length === 0) return;

    console.log(`♻️ Processing ${queue.length} task(s) from retry queue...`);

    const results = [];
    for (const task of queue) {
      const result = await handleTask(task);
      results.push({ task, result });
    }

    // Clear queue after processing
    fs.writeFileSync(QUEUE_PATH, JSON.stringify([], null, 2));
    console.log('✅ Retry queue complete.');
    return results;
  } catch (err: any) {
    console.error('❌ Failed to process retry queue:', err.message);
  }
}
