import fs from 'fs';
import path from 'path';

const LOG_PATH = path.resolve('memory', 'task_log.jsonl');

export function logTask(task: any, result: any) {
  fs.mkdirSync(path.dirname(LOG_PATH), { recursive: true });
  const logEntry = {
    timestamp: new Date().toISOString(),
    task,
    result,
  };
  fs.appendFileSync(LOG_PATH, JSON.stringify(logEntry) + '\n');
}
