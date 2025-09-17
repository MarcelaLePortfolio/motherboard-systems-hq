import fs from 'fs';
import path from 'path';

const TASKS_DIR = path.resolve('./memory/tasks');
console.log('🟢 Cade starting... task folder:', TASKS_DIR);

function processTask(file: string) {
  const filePath = path.join(TASKS_DIR, file);
  const task = JSON.parse(fs.readFileSync(filePath, 'utf-8'));

  try {
    switch (task.type) {
      case 'log':
        console.log('✅ Task log:', task.payload.message);
        task.status = 'complete';
        break;
      case 'write':
        fs.writeFileSync(path.resolve(task.payload.path), task.payload.content, 'utf-8');
        console.log(`📝 Task write: File written to ${task.payload.path}`);
        task.status = 'complete';
        break;
      case 'delete':
        if (fs.existsSync(task.payload.path)) {
          fs.unlinkSync(task.payload.path);
          console.log(`🗑️ Task delete: File removed ${task.payload.path}`);
        } else {
          console.log(`⚠️ Task delete: File not found ${task.payload.path}`);
        }
        task.status = 'complete';
        break;
      default:
        console.log(`⚠️ Unknown task type: ${task.type}`);
    }

    task.completed_at = new Date().toISOString();
    fs.writeFileSync(filePath, JSON.stringify(task, null, 2), 'utf-8');
  } catch (err) {
    console.error('❌ Error executing task:', task.id, err);
  }
}

setInterval(() => {
  const files = fs.readdirSync(TASKS_DIR).filter(f => f.endsWith('.json'));
  if (files.length) console.log('📂 Found task files:', files);
  files.forEach(processTask);
}, 3000);
