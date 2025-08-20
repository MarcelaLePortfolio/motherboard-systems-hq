import { backupMemoryFolder } from './backupMemory';
import process from 'process';
import { saveLastTask } from './saveState';

let currentTask: any = null;

export function trackTask(task: any) {
  currentTask = task;
}

export function setupGracefulShutdown() {
  const shutdown = () => {
    console.log('⚠️ Gracefully shutting down...');
    if (currentTask) {
      saveLastTask(currentTask);
    }
  backupMemoryFolder(); // 🗃️ Save zip before exit
    process.exit(0);
  };

  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}
