import fs from 'fs';
import path from 'path';

const tasksFile = path.join(process.cwd(), 'memory/chained_tasks.json');
console.log("🤖 Effie Task Poller Started");

setInterval(() => {
  if (!fs.existsSync(tasksFile)) return;
  const lines = fs.readFileSync(tasksFile, 'utf8').trim().split('\n').filter(Boolean);

  const updated = [];
  for (const line of lines) {
    const task = JSON.parse(line);
    if (task.agent === 'effie' && task.status === 'pending') {
      console.log(`⚡ Effie executing task: ${task.task}`);
      task.status = 'done';
    }
    updated.push(task);
  }

  fs.writeFileSync(tasksFile, updated.map(t => JSON.stringify(t)).join('\n') + '\n');
}, 5000);
