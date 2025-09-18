import fs from 'fs';
import path from 'path';
import { exec } from 'child_process';

const TASK_DIR = path.resolve('memory/tasks');

console.log('🟢 Matilda starting... task folder:', TASK_DIR);

setInterval(() => {
  const files = fs.readdirSync(TASK_DIR).filter(f => f.endsWith('.json'));
  if (files.length === 0) return;

  files.forEach(file => {
    const filePath = path.join(TASK_DIR, file);
    try {
      const task = JSON.parse(fs.readFileSync(filePath, 'utf8'));
      if (!task.payload || !task.payload.action) {
        console.warn('⚠️ Unknown task type: undefined', task);
        return;
      }

      switch(task.payload.action) {
        case 'runCommand':
          exec(task.payload.content, (err, stdout, stderr) => {
            if (err) console.error(err);
            if (stdout) console.log(stdout.trim());
            if (stderr) console.error(stderr.trim());
          });
          break;
        default:
          console.warn('⚠️ Unknown task type:', task.payload.action);
      }
    } catch(e) {
      console.error('❌ Failed to parse task:', file, e);
    }
  });
}, 2000);
