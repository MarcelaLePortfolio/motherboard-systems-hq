import fs from 'fs';
import path from 'path';

const tasksFile = path.join(process.cwd(), 'memory/chained_tasks.json');
console.log("🤖 Cade Task Poller Started");

setInterval(() => {
  if (!fs.existsSync(tasksFile)) return;
  const lines = fs.readFileSync(tasksFile, 'utf8').trim().split('\n').filter(Boolean);

  const updated = [];
  for (const line of lines) {
    const task = JSON.parse(line);
    // 🧠 TODO: Handle Cade's task here
    updated.push(task); // placeholder logic
  }

  // Optional: Save or process tasks
}, 2000);
