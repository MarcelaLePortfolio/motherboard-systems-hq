import fs from 'fs';
import path from 'path';

const QUEUE_PATH = path.resolve('memory', 'retry_queue.json');

export function requeueTask(task: any) {
  fs.mkdirSync(path.dirname(QUEUE_PATH), { recursive: true });

  let queue = [];
  try {
    const raw = fs.readFileSync(QUEUE_PATH, 'utf-8');
    queue = JSON.parse(raw);
  } catch {
    // If the file doesn't exist or is malformed, start fresh
  }

  queue.push({ ...task, requeuedAt: new Date().toISOString() });
  fs.writeFileSync(QUEUE_PATH, JSON.stringify(queue, null, 2));
}
