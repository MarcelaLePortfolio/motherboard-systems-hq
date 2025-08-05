import fs from 'fs';
import path from 'path';

const tasksFile = path.join(process.cwd(), 'memory/chained_tasks.json');

export function delegateTo(agent, task) {
  const taskObj = { 
    agent, 
    task, 
    timestamp: Date.now(), 
    status: 'pending' 
  };

  // Append to task list file
  fs.appendFileSync(tasksFile, JSON.stringify(taskObj) + '\n');

  // Also log to ticker as human-readable
  const tickerLog = path.join(process.cwd(), 'ui/dashboard/ticker-events.log');
  const line = `💚 matilda delegated task to ${agent}: ${task}`;
  fs.appendFileSync(tickerLog, line + '\n');

  console.log(`✅ Delegated to ${agent}: ${task}`);
}
