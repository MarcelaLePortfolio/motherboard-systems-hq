import fs from 'fs';
import path from 'path';

const TASKS_DIR = path.resolve('memory/tasks');
fs.readdirSync(TASKS_DIR).forEach(file => {
  const filePath = path.join(TASKS_DIR, file);
  const stat = fs.statSync(filePath);
  const ageMs = Date.now() - stat.mtimeMs;
  if (ageMs > 24*60*60*1000) { // older than 1 day
    fs.unlinkSync(filePath);
    console.log(`🗑️ Deleted stale task: ${file}`);
  }
});
