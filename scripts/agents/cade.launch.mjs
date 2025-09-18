
import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';

const TASK_DIR = path.resolve('memory/tasks'); // ✅ Define task folder

console.log('<0001f7e2> Cade starting... task folder:', TASK_DIR);

setInterval(() => {
  const files = fs.readdirSync(TASK_DIR).filter(f => f.endsWith('.json'));
  if (files.length === 0) return;

  files.forEach(file => {
    const filePath = path.join(TASK_DIR, file);

    try {
      const task = JSON.parse(fs.readFileSync(filePath, 'utf8'));

      if (!task.payload?.action) {
        console.warn('⚠️ Unknown task type: undefined', task);
        fs.unlinkSync(filePath); // remove malformed task
        return;
      }

      switch (task.payload.action) {
        case 'runCommand':
          try {
            execSync(task.payload.content, { stdio: 'inherit' });
            console.log('Cade executed a new task!');
          } catch (err) {
            console.error('❌ Error executing command:', err);
          } finally {
            fs.unlinkSync(filePath); // remove task after execution
          }
          break;

        default:
          console.warn('⚠️ Unknown task type:', task.payload.action);
          fs.unlinkSync(filePath); // remove unsupported task
      }
    } catch (e) {
      console.error('❌ Failed to parse task:', file, e);
      fs.unlinkSync(filePath); // remove invalid JSON
    }
  });
}, 2000);
