import fs from 'fs';
import path from 'path';

export function saveLastTask(task: any) {
  const filepath = path.resolve('memory', 'last_task.json');
  fs.mkdirSync(path.dirname(filepath), { recursive: true });
  fs.writeFileSync(filepath, JSON.stringify(task, null, 2));
}
